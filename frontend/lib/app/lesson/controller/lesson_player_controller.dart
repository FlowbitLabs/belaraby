import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Manages Text-to-Speech (TTS) playback, word splitting, and karaoke highlighting.
///
/// This controller handles the platform-specific quirks (especially for Web)
/// to ensure the Arabic voice loads correctly and playback synchronizes with word highlighting.
class LessonPlayerController extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();

  // State
  List<WordInfo> _words = [];
  int _highlightedIndex = -1;
  bool _isPlaying = false;
  
  // Internal flag to track if the TTS engine (audio context, voice selection) is ready.
  bool _isEngineReady = false;

  // Getters
  List<WordInfo> get words => _words;
  int get highlightedIndex => _highlightedIndex;
  bool get isPlaying => _isPlaying;

  /// parses text into words and sets up TTS event listeners.
  /// Note: The actual audio engine setup is "lazy" (done in speak) to satisfy Web auto-play policies.
  void init(String text) {
    _words = _parseWords(text);
    _configureEventHandlers();
    
    // Attempt to set up audio early, but don't wait for it here.
    _initializeEngine();
  }

  /// Sets up listeners for TTS events (progress, start, completion, error).
  void _configureEventHandlers() {
    _tts
      ..setProgressHandler((_, start, __, ___) {
        // Find the word that corresponds to the current character position 'start'
        final index = _words.indexWhere((w) => w.containsIndex(start));
        if (index != -1 && index != _highlightedIndex) {
          _highlightedIndex = index;
          notifyListeners();
        }
      })
      ..setStartHandler(() {
        _isPlaying = true;
        notifyListeners();
      })
      ..setCompletionHandler(_onPlaybackStopped)
      ..setErrorHandler((_) => _onPlaybackStopped());
  }

  /// Initializes the TTS engine: finds the best Arabic voice and configures speed
  /// This is "lazy safe" - it can be called multiple times but only runs once.
  Future<void> _initializeEngine() async {
    if (_isEngineReady) return;

      // 1. Find the best Arabic voice.
      // On Web, voices load asynchronously, so we retry a few times.
      final arabicVoice = await _findBestArabicVoice();
      if (arabicVoice != null) {
        await _tts.setLanguage(arabicVoice);
      } else {
        await _tts.setLanguage('ar'); // Fallback
      }

      // 2. Configure rate and sync.
      await _tts.setSpeechRate(0.5);
      // Important: 'awaitSpeakCompletion' ensures the Future returned by 
      // speak() waits until audio is actually finished. Critical for Chrome.
      await _tts.awaitSpeakCompletion(true);

    _isEngineReady = true;
  }

  /// Polls the TTS engine for available voices, retrying for up to 2 seconds.
  /// Returns a specific Arabic locale (e.g., 'ar-SA') if found.
  Future<String?> _findBestArabicVoice() async {
    dynamic voices;
    
    // Retry loop: Web browsers often return empty voices immediately after load.
    for (var i = 0; i < 5; i++) {
      voices = await _tts.getLanguages;
      if (voices is List && voices.isNotEmpty) break;
      await Future.delayed(const Duration(milliseconds: 400));
    }

    if (voices is List) {
      final voiceList = voices.map((v) => v.toString()).toList();
      // Prefer specific 'ar-' locales (like ar-SA) over generic 'ar' if possible
      return voiceList.firstWhere((v) => v.startsWith('ar'), orElse: () => 'ar');
    }
    return null;
  }

  /// Starts playback.
  /// Automatically initializes the engine if it wasn't ready (Lazy Loading pattern).
  Future<void> speak(String text) async {
    // If init failed or hasn't finished, do it now.
    // Doing this inside 'speak' works because 'speak' is triggered by a User Gesture (click),
    // which allows the browser to unlock the AudioContext.
    if (!_isEngineReady) await _initializeEngine();

    if (_isPlaying) {
      await stop();
    } else {
      await _tts.speak(text);
    }
  }

  Future<void> stop() async {
    await _tts.stop();
    _onPlaybackStopped();
  }

  void _onPlaybackStopped() {
    _isPlaying = false;
    _highlightedIndex = -1;
    notifyListeners();
  }

  /// Splits text into words using Regex, capturing start indices for highlighting.
  List<WordInfo> _parseWords(String text) {
    return RegExp(r'\S+') // Matches non-whitespace sequences
        .allMatches(text)
        .map((m) => WordInfo(word: m.group(0)!, startIndex: m.start))
        .toList();
  }

  @override
  void dispose() {
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
