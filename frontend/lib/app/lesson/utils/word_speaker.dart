import 'package:belaraby/app/lesson/utils/arabic_voice.dart';
import 'package:belaraby/app/lesson/utils/tts_engine.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// A standalone utility for speaking individual words.
///
/// Shares [sharedTts] with the story player (a second FlutterTts instance
/// would steal the story's progress callbacks and kill the karaoke
/// highlight), so it re-applies its own rate before every word and the
/// story player re-applies its rate on every start.
class WordSpeaker {
  factory WordSpeaker() => _instance;

  WordSpeaker._internal();
  static final WordSpeaker _instance = WordSpeaker._internal();

  final FlutterTts _tts = sharedTts;
  bool _isInitialized = false;

  Future<void> _initialize() async {
    if (_isInitialized) return;
    try {
      await applyBestArabicVoice(_tts);
    } on Exception {
      // Fallback to default Arabic
      await _tts.setLanguage('ar');
    }
    _isInitialized = true;
  }

  /// Speaks a single word without any highlighting or state management.
  Future<void> speak(String word) async {
    if (!_isInitialized) await _initialize();
    // Slightly below normal speed — single words are for pronunciation
    // practice, so clarity beats pace. Applied per speak because the
    // engine is shared with the story player.
    await _tts.setSpeechRate(platformNormalRate * 0.9);
    // Cut off anything still playing so rapid taps don't queue up.
    await _tts.stop();
    await _tts.speak(word);
  }
}
