import 'package:belaraby/app/lesson/utils/arabic_voice.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// A standalone utility for speaking individual words.
/// Completely separate from the lesson playback system.
class WordSpeaker {
  factory WordSpeaker() => _instance;

  WordSpeaker._internal();
  static final WordSpeaker _instance = WordSpeaker._internal();

  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      await applyBestArabicVoice(_tts);
      // Slightly below normal speed — single words are for pronunciation
      // practice, so clarity beats pace.
      await _tts.setSpeechRate(platformNormalRate * 0.9);
    } on Exception {
      // Fallback to default Arabic
      await _tts.setLanguage('ar');
    }
    _isInitialized = true;
  }

  /// Speaks a single word without any highlighting or state management.
  Future<void> speak(String word) async {
    if (!_isInitialized) await _initialize();
    // Cut off any word still playing so rapid taps don't queue up.
    await _tts.stop();
    await _tts.speak(word);
  }
}
