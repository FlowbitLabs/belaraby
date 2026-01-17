import 'package:flutter_tts/flutter_tts.dart';

/// A standalone utility for speaking individual words.
/// Completely separate from the lesson playback system.
class WordSpeaker {
  static final WordSpeaker _instance = WordSpeaker._internal();
  factory WordSpeaker() => _instance;
  
  WordSpeaker._internal();

  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      // Find and set Arabic voice
      final voices = await _tts.getLanguages;
      final arabicVoice = voices.firstWhere(
        (voice) => voice.toString().toLowerCase().contains('ar'),
        orElse: () => 'ar',
      );
      await _tts.setLanguage(arabicVoice);
      await _tts.setSpeechRate(0.5);
      _isInitialized = true;
    } catch (e) {
      // Fallback to default Arabic
      await _tts.setLanguage('ar');
      _isInitialized = true;
    }
  }

  /// Speaks a single word without any highlighting or state management.
  Future<void> speak(String word) async {
    if (!_isInitialized) await _initialize();
    await _tts.speak(word);
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  void dispose() {
    _tts.stop();
  }
}
