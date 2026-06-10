import 'package:belaraby/app/home/cubit/cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers.dart';

void main() {
  late MockLessonRepository repository;

  final lessons = [buildLesson(id: 'a'), buildLesson(id: 'b', grade: '2')];

  setUp(() {
    repository = MockLessonRepository();
  });

  HomeCubit buildCubit() => HomeCubit(repository: repository);

  group('getLessons', () {
    blocTest<HomeCubit, HomeState>(
      'emits the lessons on success',
      setUp: () {
        when(() => repository.getAllLessons()).thenAnswer((_) async => lessons);
      },
      build: buildCubit,
      act: (cubit) => cubit.getLessons(),
      expect: () => [
        const HomeState(status: HomeStatus.loading),
        HomeState(status: HomeStatus.success, lessons: lessons),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'emits error on failure',
      setUp: () {
        when(() => repository.getAllLessons()).thenThrow(Exception('boom'));
      },
      build: buildCubit,
      act: (cubit) => cubit.getLessons(),
      expect: () => [
        const HomeState(status: HomeStatus.loading),
        const HomeState(status: HomeStatus.error, error: 'Exception: boom'),
      ],
    );
  });

  group('getLessonsAfterPurchase', () {
    blocTest<HomeCubit, HomeState>(
      'uses the unlock-aware fetch after a purchase',
      setUp: () {
        when(
          () => repository.getAllLessonsUnlocked(),
        ).thenAnswer((_) async => lessons);
      },
      build: buildCubit,
      act: (cubit) => cubit.getLessonsAfterPurchase(),
      expect: () => [
        const HomeState(status: HomeStatus.loading),
        HomeState(status: HomeStatus.success, lessons: lessons),
      ],
      verify: (_) {
        verifyNever(() => repository.getAllLessons());
      },
    );

    blocTest<HomeCubit, HomeState>(
      'emits error on failure',
      setUp: () {
        when(
          () => repository.getAllLessonsUnlocked(),
        ).thenThrow(Exception('boom'));
      },
      build: buildCubit,
      act: (cubit) => cubit.getLessonsAfterPurchase(),
      expect: () => [
        const HomeState(status: HomeStatus.loading),
        const HomeState(status: HomeStatus.error, error: 'Exception: boom'),
      ],
    );
  });

  group('filters', () {
    blocTest<HomeCubit, HomeState>(
      'filterBy selects a level filter key',
      build: buildCubit,
      act: (cubit) => cubit.filterBy('level_filter_grade_2'),
      expect: () => [const HomeState(filterBy: 'level_filter_grade_2')],
    );

    blocTest<HomeCubit, HomeState>(
      'toggleHideLearned flips the flag on and off',
      build: buildCubit,
      act: (cubit) => cubit
        ..toggleHideLearned()
        ..toggleHideLearned(),
      expect: () => [
        const HomeState(hideLearned: true),
        const HomeState(),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'updateLearnedIds mirrors the global learned set',
      build: buildCubit,
      act: (cubit) => cubit.updateLearnedIds({'a'}),
      expect: () => [
        const HomeState(learnedIds: {'a'}),
      ],
    );

    test('hide-learned combines the flag with the learned ids', () async {
      when(() => repository.getAllLessons()).thenAnswer((_) async => lessons);

      final cubit = buildCubit();
      await cubit.getLessons();
      cubit
        ..updateLearnedIds({'a'})
        ..toggleHideLearned();
      expect(
        cubit.state.paidLessonsBySelectedLevel.map((lesson) => lesson.id),
        ['b'],
      );

      // Switching the flag off shows the learned lesson again.
      cubit.toggleHideLearned();
      expect(
        cubit.state.paidLessonsBySelectedLevel.map((lesson) => lesson.id),
        ['a', 'b'],
      );
      await cubit.close();
    });
  });
}
