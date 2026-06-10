import 'package:belaraby/app/lesson/cubit/lesson_unlock_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers.dart';

void main() {
  late MockLessonRepository repository;

  // A paid lesson with an empty body is still masked server-side.
  final maskedLesson = buildLesson(body: '');
  final unlockedLesson = buildLesson();

  setUp(() {
    repository = MockLessonRepository();
  });

  LessonUnlockCubit buildCubit() =>
      LessonUnlockCubit(lesson: maskedLesson, repository: repository);

  blocTest<LessonUnlockCubit, LessonUnlockState>(
    'emits success once the body is unlocked',
    setUp: () {
      when(
        () => repository.getUnlockedLessonById(maskedLesson.id),
      ).thenAnswer((_) async => unlockedLesson);
    },
    build: buildCubit,
    act: (cubit) => cubit.waitForUnlock(),
    expect: () => [
      const LessonUnlockState(status: LessonUnlockStatus.loading),
      LessonUnlockState(
        status: LessonUnlockStatus.success,
        lesson: unlockedLesson,
      ),
    ],
  );

  blocTest<LessonUnlockCubit, LessonUnlockState>(
    'emits timeout when the body is still masked after the retry budget',
    setUp: () {
      when(
        () => repository.getUnlockedLessonById(maskedLesson.id),
      ).thenAnswer((_) async => maskedLesson);
    },
    build: buildCubit,
    act: (cubit) => cubit.waitForUnlock(),
    expect: () => [
      const LessonUnlockState(status: LessonUnlockStatus.loading),
      LessonUnlockState(
        status: LessonUnlockStatus.timeout,
        lesson: maskedLesson,
      ),
    ],
  );

  blocTest<LessonUnlockCubit, LessonUnlockState>(
    'emits error when the lesson disappeared server-side',
    setUp: () {
      when(
        () => repository.getUnlockedLessonById(maskedLesson.id),
      ).thenAnswer((_) async => null);
    },
    build: buildCubit,
    act: (cubit) => cubit.waitForUnlock(),
    expect: () => [
      const LessonUnlockState(status: LessonUnlockStatus.loading),
      const LessonUnlockState(status: LessonUnlockStatus.error),
    ],
  );

  blocTest<LessonUnlockCubit, LessonUnlockState>(
    'emits error when the fetch throws',
    setUp: () {
      when(
        () => repository.getUnlockedLessonById(maskedLesson.id),
      ).thenThrow(Exception('boom'));
    },
    build: buildCubit,
    act: (cubit) => cubit.waitForUnlock(),
    expect: () => [
      const LessonUnlockState(status: LessonUnlockStatus.loading),
      const LessonUnlockState(status: LessonUnlockStatus.error),
    ],
  );
}
