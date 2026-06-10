import 'package:belaraby/app/lesson/cubit/favorite_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers.dart';

void main() {
  late MockLibraryRepository repository;

  setUp(() {
    repository = MockLibraryRepository();
  });

  FavoriteCubit buildCubit() => FavoriteCubit(repository: repository);

  group('loadFavorites', () {
    blocTest<FavoriteCubit, FavoriteState>(
      'emits the favorite lesson ids on success',
      setUp: () {
        when(() => repository.fetchFavorites()).thenAnswer(
          (_) async => [buildLesson(id: 'a'), buildLesson(id: 'b')],
        );
      },
      build: buildCubit,
      act: (cubit) => cubit.loadFavorites(),
      expect: () => [
        const FavoriteState(status: FavoriteStatus.loading),
        const FavoriteState(
          status: FavoriteStatus.success,
          favoriteIds: {'a', 'b'},
        ),
      ],
    );

    blocTest<FavoriteCubit, FavoriteState>(
      'emits error and keeps the previous ids on failure',
      setUp: () {
        when(() => repository.fetchFavorites()).thenThrow(Exception('boom'));
      },
      build: buildCubit,
      seed: () => const FavoriteState(
        status: FavoriteStatus.success,
        favoriteIds: {'a'},
      ),
      act: (cubit) => cubit.loadFavorites(),
      expect: () => [
        const FavoriteState(
          status: FavoriteStatus.loading,
          favoriteIds: {'a'},
        ),
        const FavoriteState(status: FavoriteStatus.error, favoriteIds: {'a'}),
      ],
    );
  });

  group('toggleFavorite', () {
    blocTest<FavoriteCubit, FavoriteState>(
      'adds optimistically and bumps syncCount once the write settles',
      setUp: () {
        when(() => repository.addFavorite('a')).thenAnswer((_) async {});
      },
      build: buildCubit,
      act: (cubit) => cubit.toggleFavorite('a'),
      expect: () => [
        // Optimistic update happens before the backend call returns.
        const FavoriteState(
          status: FavoriteStatus.success,
          favoriteIds: {'a'},
        ),
        const FavoriteState(
          status: FavoriteStatus.success,
          favoriteIds: {'a'},
          syncCount: 1,
        ),
      ],
      verify: (_) {
        verify(() => repository.addFavorite('a')).called(1);
        verifyNever(() => repository.removeFavorite(any()));
      },
    );

    blocTest<FavoriteCubit, FavoriteState>(
      'removes optimistically when the lesson is already a favorite',
      setUp: () {
        when(() => repository.removeFavorite('a')).thenAnswer((_) async {});
      },
      build: buildCubit,
      seed: () => const FavoriteState(
        status: FavoriteStatus.success,
        favoriteIds: {'a'},
      ),
      act: (cubit) => cubit.toggleFavorite('a'),
      expect: () => [
        const FavoriteState(status: FavoriteStatus.success),
        const FavoriteState(status: FavoriteStatus.success, syncCount: 1),
      ],
      verify: (_) {
        verify(() => repository.removeFavorite('a')).called(1);
      },
    );

    blocTest<FavoriteCubit, FavoriteState>(
      'reverts the optimistic update and reports an error on failure',
      setUp: () {
        when(() => repository.addFavorite('a')).thenThrow(Exception('boom'));
      },
      build: buildCubit,
      act: (cubit) => cubit.toggleFavorite('a'),
      expect: () => [
        const FavoriteState(
          status: FavoriteStatus.success,
          favoriteIds: {'a'},
        ),
        const FavoriteState(
          status: FavoriteStatus.error,
          errorMessage: 'favorites_update_error',
        ),
      ],
    );

    blocTest<FavoriteCubit, FavoriteState>(
      'does not bump syncCount when the write fails',
      setUp: () {
        when(
          () => repository.removeFavorite('a'),
        ).thenThrow(Exception('boom'));
      },
      build: buildCubit,
      seed: () => const FavoriteState(
        status: FavoriteStatus.success,
        favoriteIds: {'a'},
        syncCount: 3,
      ),
      act: (cubit) => cubit.toggleFavorite('a'),
      expect: () => [
        const FavoriteState(status: FavoriteStatus.success, syncCount: 3),
        const FavoriteState(
          status: FavoriteStatus.error,
          favoriteIds: {'a'},
          errorMessage: 'favorites_update_error',
          syncCount: 3,
        ),
      ],
    );
  });
}
