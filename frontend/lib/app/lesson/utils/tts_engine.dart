import 'package:flutter_tts/flutter_tts.dart';

/// The app-wide TTS engine.
///
/// flutter_tts routes ALL engine callbacks (progress/start/completion) to
/// the most recently constructed [FlutterTts] instance — a second instance
/// silently steals the story player's karaoke events. Every speaker must
/// therefore share this single instance and re-apply its own speech rate
/// before speaking.
final FlutterTts sharedTts = FlutterTts();
