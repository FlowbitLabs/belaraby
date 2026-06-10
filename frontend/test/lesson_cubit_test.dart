import 'package:belaraby/app/lesson/cubit/learned_cubit.dart';
import 'package:belaraby/app/lesson/cubit/lesson_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers.dart';

void main() {
  late MockLibraryRepository repository;

  setUp(() {
    repository = MockLibraryRepository();
  });

  group('LessonCubit', () {
    LessonCubit buildCubit() =>
        LessonCubit(lessonId: 'a', repository: repository);

    group('loadLearnedStatus', () {
      blocTest<LessonCubit, LessonState>(
        'emits the learned status on success',
        setUp: () {
          when(() => repository.isLearned('a')).thenAnswer((_) async => true);
        },
        build: buildCubit,
        act: (cubit) => cubit.loadLearnedStatus(),
        expect: () => [
          const LessonState(status: LessonStatus.loading),
          const LessonState(status: LessonStatus.success, isLearned: true),
        ],
      );

      blocTest<LessonCubit, LessonState>(
        'emits error on failure',
        setUp: () {
          when(() => repository.isLearned('a')).thenThrow(Exception('boom'));
        },
        build: buildCubit,
        act: (cubit) => cubit.loadLearnedStatus(),
        expect: () => [
          const LessonState(status: LessonStatus.loading),
          const LessonState(status: LessonStatus.error),
        ],
      );
    });

    group('toggleLearned', () {
      blocTest<LessonCubit, LessonState>(
        'marks optimistically and persists',
        setUp: () {
          when(() => repository.markLearned('a')).thenAnswer((_) async {});
        },
        build: buildCubit,
        act: (cubit) => cubit.toggleLearned(),
        expect: () => [
          const LessonState(status: LessonStatus.success, isLearned: true),
        ],
        verify: (_) {
          verify(() => repository.markLearned('a')).called(1);
          verifyNever(() => repository.unmarkLearned(any()));
        },
      );

      blocTest<LessonCubit, LessonState>(
        'unmarks when the lesson was already learned',
        setUp: () {
          when(() => repository.unmarkLearned('a')).thenAnswer((_) async {});
        },
        build: buildCubit,
        seed: () => const LessonState(
          status: LessonStatus.success,
          isLearned: true,
        ),
        act: (cubit) => cubit.toggleLearned(),
        expect: () => [const LessonState(status: LessonStatus.success)],
        verify: (_) {
          verify(() => repository.unmarkLearned('a')).called(1);
        },
      );

      blocTest<LessonCubit, LessonState>(
        'reverts the optimistic toggle and reports an error on failure',
        setUp: () {
          when(() => repository.markLearned('a')).thenThrow(Exception('boom'));
        },
        build: buildCubit,
        act: (cubit) => cubit.toggleLearned(),
        expect: () => [
          const LessonState(status: LessonStatus.success, isLearned: true),
          const LessonState(
            status: LessonStatus.error,
            errorMessage: 'learned_update_error',
          ),
        ],
      );
    });
  });

  group('LearnedCubit', () {
    LearnedCubit buildCubit() => LearnedCubit(repository: repository);

    group('loadLearned', () {
      blocTest<LearnedCubit, LearnedState>(
        'emits the learned lesson ids on success',
        setUp: () {
          when(() => repository.fetchLearned()).thenAnswer(
            (_) async => [buildLesson(id: 'a'), buildLesson(id: 'b')],
          );
        },
        build: buildCubit,
        act: (cubit) => cubit.loadLearned(),
        expect: () => [
          const LearnedState(status: LearnedStatus.loading),
          const LearnedState(
            status: LearnedStatus.success,
            learnedIds: {'a', 'b'},
          ),
        ],
      );

      blocTest<LearnedCubit, LearnedState>(
        'emits error on failure',
        setUp: () {
          when(() => repository.fetchLearned()).thenThrow(Exception('boom'));
        },
        build: buildCubit,
        act: (cubit) => cubit.loadLearned(),
        expect: () => [
          const LearnedState(status: LearnedStatus.loading),
          const LearnedState(status: LearnedStatus.error),
        ],
      );
    });

    group('setLearned', () {
      blocTest<LearnedCubit, LearnedState>(
        'adds and removes ids locally without touching the repository',
        build: buildCubit,
        act: (cubit) => cubit
          ..setLearned('a', isLearned: true)
          ..setLearned('a', isLearned: false),
        expect: () => [
          const LearnedState(status: LearnedStatus.success, learnedIds: {'a'}),
          const LearnedState(status: LearnedStatus.success),
        ],
        verify: (_) {
          verifyZeroInteractions(repository);
        },
      );

      blocTest<LearnedCubit, LearnedState>(
        'emits nothing when the id set does not change',
        build: buildCubit,
        seed: () => const LearnedState(
          status: LearnedStatus.success,
          learnedIds: {'a'},
        ),
        act: (cubit) => cubit.setLearned('a', isLearned: true),
        expect: () => const <LearnedState>[],
      );
    });
  });
}
