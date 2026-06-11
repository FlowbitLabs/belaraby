import 'dart:async';

import 'package:belaraby/app/lesson/utils/arabic_voice.dart';
import 'package:belaraby/app/lesson/utils/tts_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Playback speed steps, as multiples of the platform's normal rate.
const List<double> storySpeedFactors = [0.7, 1, 1.3];

/// Arabic display labels for [storySpeedFactors].
const List<String> storySpeedLabels = ['٠٫٧×', '١×', '١٫٣×'];

/// Index of the default (normal) speed in [storySpeedFactors].
const int _normalSpeedIndex = 1;

const String _speedPrefsKey = 'story_speed_index';

/// Manages Text-to-Speech (TTS) playback, word splitting, and karaoke
/// highlighting.
///
/// Handles the platform-specific quirks (especially for Web) to ensure the
/// Arabic voice loads correctly and playback synchronizes with word
/// highlighting. Supports pause/resume (implemented as stop + re-speak from
/// the current word, which works on every platform) and a persisted
/// playback-speed setting.
class LessonPlayerController extends ChangeNotifier {
  LessonPlayerController({FlutterTts? tts, SharedPreferences? preferences})
    : _tts = tts ?? sharedTts,
      _preferences = preferences;

  final FlutterTts _tts;
  SharedPreferences? _preferences;

  // State
  List<WordInfo> _words = [];
  String _text = '';
  int _highlightedIndex = -1;
  bool _isPlaying = false;
  bool _isPaused = false;
  int _speedIndex = _normalSpeedIndex;

  /// Word index playback resumes from after a pause.
  int _resumeWordIndex = 0;

  /// Character offset of the current utterance inside the full story —
  /// non-zero after a resume, where only a suffix of the text is spoken.
  int _charOffset = 0;

  /// Incremented on every stop/pause so stale engine callbacks (the engines
  /// fire completion for cancelled utterances too) can be ignored.
  int _utteranceGeneration = 0;

  /// Memoized engine setup so concurrent callers share one initialization.
  Future<void>? _engineInit;

  /// Guards against concurrent speak/pause calls from rapid taps.
  bool _busy = false;

  /// Set while a story utterance we initiated is starting, so start events
  /// caused by other users of the shared engine (WordSpeaker) are ignored.
  bool _expectingStart = false;

  /// Invoked after playback completes naturally to optionally repeat the
  /// lesson. Never invoked for manual stops, pauses or engine errors.
  Future<void> Function()? onRepeat;

  /// The story split into words, in document order.
  List<WordInfo> get words => _words;

  /// Index into [words] of the word currently being spoken, or -1.
  int get highlightedIndex => _highlightedIndex;

  /// Whether story playback is in progress.
  bool get isPlaying => _isPlaying;

  /// Whether playback is paused mid-story (resumable).
  bool get isPaused => _isPaused;

  /// Arabic label of the current playback speed (e.g. `١×`).
  String get speedLabel => storySpeedLabels[_speedIndex];

  /// Parses text into words and sets up TTS event listeners.
  ///
  /// The actual audio engine setup is "lazy" (finished in [speak]) to
  /// satisfy Web auto-play policies.
  void init(String text) {
    _text = text;
    _words = _parseWords(text);
    _configureEventHandlers();

    // Attempt to set up audio early, but don't wait for it here.
    unawaited(_initializeEngine());
  }

  /// Sets up listeners for TTS events (progress, start, completion, error).
  void _configureEventHandlers() {
    _tts
      ..setProgressHandler((_, start, _, _) {
        // Map the utterance-relative character position back into the full
        // story (the utterance may be a suffix after a resume).
        final absoluteStart = start + _charOffset;
        final index = _words.indexWhere((w) => w.containsIndex(absoluteStart));
        if (index != -1 && index != _highlightedIndex) {
          _highlightedIndex = index;
          notifyListeners();
        }
      })
      ..setStartHandler(() {
        // The engine is shared with WordSpeaker — only starts we initiated
        // (via _startFrom) may flip the playback state.
        if (!_expectingStart) return;
        _expectingStart = false;
        _isPlaying = true;
        _isPaused = false;
        notifyListeners();
      })
      ..setCompletionHandler(() {
        unawaited(_onNaturalCompletion(_utteranceGeneration));
      })
      ..setErrorHandler((Object? _) {
        _onErrorOrCancel(_utteranceGeneration);
      });
  }

  /// Initializes the TTS engine: picks the best Arabic voice, restores the
  /// saved speed and configures completion awaiting. Safe to call multiple
  /// times; only runs once.
  Future<void> _initializeEngine() => _engineInit ??= _setUpEngine();

  Future<void> _setUpEngine() async {
    await applyBestArabicVoice(_tts);

    _preferences ??= await SharedPreferences.getInstance();
    final savedIndex = _preferences?.getInt(_speedPrefsKey);
    if (savedIndex != null &&
        savedIndex >= 0 &&
        savedIndex < storySpeedFactors.length) {
      _speedIndex = savedIndex;
    }
    await _applyRate();

    // 'awaitSpeakCompletion' ensures the Future returned by speak() waits
    // until audio is actually finished. Critical for Chrome.
    await _tts.awaitSpeakCompletion(true);

    notifyListeners();
  }

  Future<void> _applyRate() async {
    await _tts.setSpeechRate(
      platformNormalRate * storySpeedFactors[_speedIndex],
    );
  }

  /// Play / pause toggle.
  ///
  /// Starts the story from the beginning when idle, pauses when playing,
  /// and resumes from the paused word when paused. Triggered by a user
  /// gesture, which also unlocks the browser AudioContext on web.
  Future<void> speak(String text) async {
    if (_busy) return;
    _busy = true;
    try {
      await _initializeEngine();

      if (_isPlaying) {
        await _pause();
      } else {
        if (text != _text) {
          // New text (defensive — the view passes the same story).
          init(text);
          _resumeWordIndex = 0;
        }
        await _startFrom(_isPaused ? _resumeWordIndex : 0);
      }
    } finally {
      _busy = false;
    }
  }

  /// Cycles to the next playback speed and persists it. When invoked
  /// mid-playback the current utterance restarts from the highlighted word
  /// at the new speed (engines don't re-rate in-flight utterances).
  Future<void> cycleSpeed() async {
    _speedIndex = (_speedIndex + 1) % storySpeedFactors.length;
    _preferences ??= await SharedPreferences.getInstance();
    await _preferences?.setInt(_speedPrefsKey, _speedIndex);
    await _applyRate();
    notifyListeners();

    if (_isPlaying) {
      final fromWord = _highlightedIndex >= 0 ? _highlightedIndex : 0;
      _utteranceGeneration++;
      _isPlaying = false; // see [stop] — guards the web cancel callback
      await _tts.stop();
      await _startFrom(fromWord);
    }
  }

  /// Stops playback completely and clears highlight + resume state.
  ///
  /// State is cleared BEFORE the engine stop: on web, cancelling an
  /// utterance fires the completion handler synchronously inside
  /// `_tts.stop()`, and the handler must already see `isPlaying == false`
  /// so it doesn't treat the cancellation as a natural completion.
  Future<void> stop() async {
    _utteranceGeneration++;
    _isPlaying = false;
    _isPaused = false;
    _highlightedIndex = -1;
    _resumeWordIndex = 0;
    _charOffset = 0;
    notifyListeners();
    await _tts.stop();
  }

  Future<void> _pause() async {
    // Resume from the word being spoken (or the start when unknown).
    _resumeWordIndex = _highlightedIndex >= 0 ? _highlightedIndex : 0;
    _utteranceGeneration++;
    // Same ordering as [stop]: flip the state before the engine stop so
    // the synchronous web completion callback can't wipe the pause state.
    _isPlaying = false;
    _isPaused = true;
    notifyListeners();
    await _tts.stop();
  }

  Future<void> _startFrom(int wordIndex) async {
    if (_words.isEmpty) return;
    // The engine is shared with WordSpeaker, which sets its own rate —
    // re-apply ours before every story start.
    await _applyRate();
    final index = wordIndex.clamp(0, _words.length - 1);
    _charOffset = _words[index].startIndex;
    _highlightedIndex = index;
    _isPlaying = true;
    _isPaused = false;
    _expectingStart = true;
    notifyListeners();
    // Fire and forget: with awaitSpeakCompletion(true) this future only
    // resolves when the audio FINISHES — awaiting it here would hold the
    // _busy guard for the whole story and deadlock every control tap.
    // Completion/errors are handled by the engine handlers instead.
    final generation = _utteranceGeneration;
    unawaited(
      _tts.speak(_text.substring(_charOffset)).catchError((Object error) {
        debugPrint('LessonPlayerController.speak failed: $error');
        _onErrorOrCancel(generation);
        return null;
      }),
    );
  }

  /// Natural end of the utterance: reset and fire the repeat hook.
  Future<void> _onNaturalCompletion(int generation) async {
    // Completions fired by cancelled utterances must not reset state or
    // trigger repeat. Stop/pause/speed-change all flip _isPlaying to false
    // BEFORE cancelling the engine, so anything arriving while not playing
    // is a cancellation echo, not a natural end.
    if (!_isPlaying) return;
    if (generation != _utteranceGeneration) return;

    _isPlaying = false;
    _isPaused = false;
    _highlightedIndex = -1;
    _resumeWordIndex = 0;
    _charOffset = 0;
    notifyListeners();

    if (onRepeat != null) {
      await Future<void>.delayed(const Duration(seconds: 1));
      // Re-check: the user may have started playback again or left.
      if (!_isPlaying && generation == _utteranceGeneration) {
        await onRepeat!();
      }
    }
  }

  void _onErrorOrCancel(int generation) {
    if (!_isPlaying) return;
    if (generation != _utteranceGeneration) return;
    _isPlaying = false;
    _isPaused = false;
    _highlightedIndex = -1;
    notifyListeners();
  }

  /// Splits text into words using Regex, capturing start indices for
  /// highlighting.
  List<WordInfo> _parseWords(String text) {
    return RegExp(r'\S+') // Matches non-whitespace sequences
        .allMatches(text)
        .map((m) => WordInfo(word: m.group(0)!, startIndex: m.start))
        .toList();
  }

  @override
  void dispose() {
    _utteranceGeneration++;
    _tts.stop();
    super.dispose();
  }
}

/// Simple model representing a word and its position in the text.
class WordInfo {
  const WordInfo({required this.word, required this.startIndex});

  final String word;
  final int startIndex;

  /// Checks if the given character index falls within this word.
  bool containsIndex(int charIndex) {
    return charIndex >= startIndex && charIndex < startIndex + word.length;
  }
}
