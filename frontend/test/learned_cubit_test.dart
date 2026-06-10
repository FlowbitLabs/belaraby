import 'package:belaraby/app/lesson/cubit/learned_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers.dart';

void main() {
  late MockLibraryRepository repository;

  setUp(() {
    repository = MockLibraryRepository();
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

    group('toggleLearned', () {
      blocTest<LearnedCubit, LearnedState>(
        'marks optimistically, then bumps syncCount once persisted',
        setUp: () {
          when(() => repository.markLearned('a')).thenAnswer((_) async {});
        },
        build: buildCubit,
        act: (cubit) => cubit.toggleLearned('a'),
        expect: () => [
          const LearnedState(
            status: LearnedStatus.success,
            learnedIds: {'a'},
          ),
          const LearnedState(
            status: LearnedStatus.success,
            learnedIds: {'a'},
            syncCount: 1,
          ),
        ],
        verify: (_) {
          verify(() => repository.markLearned('a')).called(1);
          verifyNever(() => repository.unmarkLearned(any()));
        },
      );

      blocTest<LearnedCubit, LearnedState>(
        'unmarks when the lesson was already learned',
        setUp: () {
          when(() => repository.unmarkLearned('a')).thenAnswer((_) async {});
        },
        build: buildCubit,
        seed: () => const LearnedState(
          status: LearnedStatus.success,
          learnedIds: {'a'},
        ),
        act: (cubit) => cubit.toggleLearned('a'),
        expect: () => [
          const LearnedState(status: LearnedStatus.success),
          const LearnedState(status: LearnedStatus.success, syncCount: 1),
        ],
        verify: (_) {
          verify(() => repository.unmarkLearned('a')).called(1);
        },
      );

      blocTest<LearnedCubit, LearnedState>(
        'reverts the optimistic toggle and reports an error on failure',
        setUp: () {
          when(() => repository.markLearned('a')).thenThrow(Exception('boom'));
        },
        build: buildCubit,
        act: (cubit) => cubit.toggleLearned('a'),
        expect: () => [
          const LearnedState(
            status: LearnedStatus.success,
            learnedIds: {'a'},
          ),
          const LearnedState(
            status: LearnedStatus.error,
            errorMessage: 'learned_update_error',
          ),
        ],
        verify: (_) {
          // The settle signal must not fire when the write failed.
          verifyNever(() => repository.unmarkLearned(any()));
        },
      );

      blocTest<LearnedCubit, LearnedState>(
        'does not bump syncCount on failure',
        setUp: () {
          when(() => repository.markLearned('a')).thenThrow(Exception('boom'));
        },
        build: buildCubit,
        act: (cubit) => cubit.toggleLearned('a'),
        verify: (cubit) {
          expect(cubit.state.syncCount, 0);
        },
      );
    });
  });
}
