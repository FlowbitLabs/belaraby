import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

/// Manages Text-to-Speech (TTS) playback and word highlighting for lessons.
/// 
/// - Splits lesson text into [WordInfo] objects.
/// - Tracks playback progress to highlight the current word.
/// - Exposes callbacks for UI updates to avoid direct dependency on Flutter Widgets.
class LessonPlayerController {
  final FlutterTts _flutterTts = FlutterTts();
  List<WordInfo> _wordInfoList = [];
  
  // Callbacks for UI updates
  void Function(int wordIndex)? onWordHighlighted;
  void Function(bool isPlaying)? onPlayingStateChanged;
  void Function()? onCompleted;

  int _currentWordIndex = -1;
  bool _isPlaying = false;

  int get currentWordIndex => _currentWordIndex;
  bool get isPlaying => _isPlaying;
  List<WordInfo> get wordInfoList => _wordInfoList;

  Future<void> init(String text) async {
    _wordInfoList = _splitText(text);
    
    await _flutterTts.setLanguage('ar');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.awaitSpeakCompletion(true);

    _flutterTts
      ..setProgressHandler((_, start, _, _) {
        // 'start' is the character index in the full text string.
        // We find which word range contains this index to highlight the correct word.
        final index = _wordInfoList.indexWhere(
          (w) => start >= w.start && start < w.start + w.word.length,
        );
        if (index != -1 && index != _currentWordIndex) {
          _currentWordIndex = index;
          onWordHighlighted?.call(index);
        }
      })
      ..setStartHandler(() {
        _isPlaying = true;
        onPlayingStateChanged?.call(true);
      })
      ..setCompletionHandler(() {
        _reset();
        onCompleted?.call();
      })
      ..setErrorHandler((_) {
        _reset();
        onPlayingStateChanged?.call(false);
      });
  }

  Future<void> speak(String text) async {
    if (_isPlaying) {
      await stop();
    } else {
      await _flutterTts.speak(text);
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _reset();
  }

  void _reset() {
    _isPlaying = false;
    _currentWordIndex = -1;
    onPlayingStateChanged?.call(false);
    onWordHighlighted?.call(-1);
  }

  List<WordInfo> _splitText(String text) {
    // Regex \S+ matches any non-whitespace character sequence.
    // This allows us to track start/end indices for highlighting functionality.
    final regex = RegExp(r'\S+');
    return regex
        .allMatches(text)
        .map((m) => WordInfo(m.group(0)!, m.start))
        .toList();
  }
  
  void dispose() {
    _flutterTts.stop();
  }
}

class WordInfo {
  const WordInfo(this.word, this.start);
  final String word;
  final int start;
}
