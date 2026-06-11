import 'dart:async';

import 'package:belaraby/app/lesson/controller/lesson_player_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockFlutterTts extends Mock implements FlutterTts {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFlutterTts tts;
  late LessonPlayerController controller;
  ProgressHandler? progressHandler;
  VoidCallback? completionHandler;

  const story = 'كلمة أولى ثم ثانية';

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    tts = MockFlutterTts();
    progressHandler = null;
    completionHandler = null;

    when(() => tts.setProgressHandler(any())).thenAnswer((invocation) {
      progressHandler =
          invocation.positionalArguments.first as ProgressHandler;
    });
    when(() => tts.setStartHandler(any())).thenReturn(null);
    when(() => tts.setCompletionHandler(any())).thenAnswer((invocation) {
      completionHandler =
          invocation.positionalArguments.first as VoidCallback;
    });
    when(() => tts.setErrorHandler(any())).thenReturn(null);
    when(() => tts.getVoices).thenAnswer(
      (_) async => [
        // "Arthur" must NOT match as Arabic (regression: name starts
        // with "ar", which once beat the real Arabic voices).
        {'name': 'Arthur', 'locale': 'en-GB'},
        {'name': 'Basic Arabic', 'locale': 'ar-EG'},
        {'name': 'Google العربية', 'locale': 'ar-SA'},
        {'name': 'English Voice', 'locale': 'en-US'},
      ],
    );
    when(() => tts.setVoice(any())).thenAnswer((_) async => 1);
    when(() => tts.setLanguage(any())).thenAnswer((_) async => 1);
    when(() => tts.setPitch(any())).thenAnswer((_) async => 1);
    when(() => tts.setSpeechRate(any())).thenAnswer((_) async => 1);
    when(() => tts.awaitSpeakCompletion(any())).thenAnswer((_) async => 1);
    when(() => tts.speak(any())).thenAnswer((_) async => 1);
    when(() => tts.stop()).thenAnswer((_) async => 1);

    controller = LessonPlayerController(
      tts: tts,
      preferences: await SharedPreferences.getInstance(),
    )..init(story);
  });

  test('parses the story into words with start indices', () {
    expect(controller.words.map((w) => w.word).toList(), [
      'كلمة',
      'أولى',
      'ثم',
      'ثانية',
    ]);
    expect(controller.words[1].containsIndex(5), isTrue);
    expect(controller.words[1].containsIndex(4), isFalse);
  });

  test('selects the highest-quality Arabic voice and sets its language',
      () async {
    await controller.speak(story);
    verify(
      () => tts.setVoice({'name': 'Google العربية', 'locale': 'ar-SA'}),
    ).called(1);
    // The language tag is the safety net: engines where the voice lookup
    // silently fails would otherwise speak with the default (English)
    // voice — which reads Arabic text as "dot dot dot".
    verify(() => tts.setLanguage('ar-SA')).called(1);
  });

  test('speak starts playback and highlights via progress events', () async {
    await controller.speak(story);
    expect(controller.isPlaying, isTrue);
    verify(() => tts.speak(story)).called(1);

    progressHandler!(story, 5, 9, 'أولى');
    expect(controller.highlightedIndex, 1);
  });

  test('speak while playing pauses; speaking again resumes from the word',
      () async {
    await controller.speak(story);
    progressHandler!(story, 5, 9, 'أولى');

    await controller.speak(story); // pause
    expect(controller.isPlaying, isFalse);
    expect(controller.isPaused, isTrue);

    await controller.speak(story); // resume
    expect(controller.isPlaying, isTrue);
    // Resumes from "أولى" (index 5), not from the beginning.
    verify(() => tts.speak(story.substring(5))).called(1);
  });

  test('progress offsets map back to story words after a resume', () async {
    await controller.speak(story);
    progressHandler!(story, 5, 9, 'أولى');
    await controller.speak(story); // pause on "أولى"
    await controller.speak(story); // resume — utterance starts at char 5

    // "ثم" starts at char 10 of the story = char 5 of the new utterance.
    progressHandler!(story.substring(5), 5, 7, 'ثم');
    expect(controller.highlightedIndex, 2);
  });

  test('stop clears playback, pause and highlight state', () async {
    await controller.speak(story);
    progressHandler!(story, 5, 9, 'أولى');

    await controller.stop();
    expect(controller.isPlaying, isFalse);
    expect(controller.isPaused, isFalse);
    expect(controller.highlightedIndex, -1);

    // After stop, playback restarts from the very beginning (the full
    // story is spoken again — no resume offset survives a stop).
    await controller.speak(story);
    verify(() => tts.speak(story)).called(2);
  });

  test('repeat fires only on natural completion, not on manual stop',
      () async {
    var repeats = 0;
    controller.onRepeat = () async => repeats++;

    await controller.speak(story);
    await controller.stop(); // manual stop — no repeat
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    expect(repeats, 0);

    await controller.speak(story);
    completionHandler!(); // natural end — repeat fires after the delay
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    expect(repeats, 1);
  });

  test('controls stay responsive while the utterance future is in flight',
      () async {
    // With awaitSpeakCompletion(true) the speak() future resolves only
    // when the audio finishes — controls must not block on it.
    when(() => tts.speak(any())).thenAnswer((_) => Completer<int>().future);

    await controller.speak(story); // starts playing, future never resolves
    expect(controller.isPlaying, isTrue);

    await controller.speak(story); // pause must still go through
    expect(controller.isPaused, isTrue);

    await controller.cycleSpeed(); // and so must speed changes
    expect(controller.speedLabel, '١٫٣×');

    await controller.stop();
    expect(controller.isPlaying, isFalse);
  });

  test('cycleSpeed cycles labels, persists, and re-rates the engine',
      () async {
    await controller.speak(story);
    expect(controller.speedLabel, '١×');

    await controller.cycleSpeed();
    expect(controller.speedLabel, '١٫٣×');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('story_speed_index'), 2);
    // Mid-play speed change restarts the utterance at the new rate.
    expect(controller.isPlaying, isTrue);

    await controller.cycleSpeed();
    expect(controller.speedLabel, '٠٫٧×');
    await controller.cycleSpeed();
    expect(controller.speedLabel, '١×');
  });
}
