import 'package:belaraby/data/repositories/library_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum FavoriteStatus { initial, loading, success, error }

/// Global cubit holding the ids of the user's favorite lessons.
///
/// Toggles are optimistic: the UI updates immediately and reverts (with an
/// error message) when the backend call fails.
class FavoriteCubit extends Cubit<FavoriteState> {
  FavoriteCubit({LibraryRepository? repository})
    : _repository = repository ?? LibraryRepository(),
      super(const FavoriteState());

  final LibraryRepository _repository;

  /// Loads the user's favorite lesson ids.
  Future<void> loadFavorites() async {
    emit(state.copyWith(status: FavoriteStatus.loading, errorMessage: ''));
    try {
      final favorites = await _repository.fetchFavorites();
      emit(
        state.copyWith(
          status: FavoriteStatus.success,
          favoriteIds: favorites.map((lesson) => lesson.id).toSet(),
        ),
      );
    } on Exception catch (error) {
      debugPrint('FavoriteCubit.loadFavorites failed: $error');
      emit(state.copyWith(status: FavoriteStatus.error));
    }
  }

  /// Adds or removes [lessonId] from the favorites, optimistically.
  Future<void> toggleFavorite(String lessonId) async {
    final previousIds = state.favoriteIds;
    final wasFavorite = previousIds.contains(lessonId);
    final optimisticIds = Set<String>.of(previousIds);
    if (wasFavorite) {
      optimisticIds.remove(lessonId);
    } else {
      optimisticIds.add(lessonId);
    }
    emit(
      state.copyWith(
        status: FavoriteStatus.success,
        favoriteIds: optimisticIds,
        errorMessage: '',
      ),
    );
    try {
      if (wasFavorite) {
        await _repository.removeFavorite(lessonId);
      } else {
        await _repository.addFavorite(lessonId);
      }
      // Signal that the backend write settled: listeners that refetch
      // favorites (e.g. My Library) must key off [FavoriteState.syncCount],
      // not the optimistic id change, or their GET races the write.
      emit(state.copyWith(syncCount: state.syncCount + 1));
    } on Exception catch (error) {
      debugPrint('FavoriteCubit.toggleFavorite failed: $error');
      emit(
        state.copyWith(
          status: FavoriteStatus.error,
          favoriteIds: previousIds,
          errorMessage: 'favorites_update_error',
        ),
      );
    }
  }
}

class FavoriteState extends Equatable {
  const FavoriteState({
    this.status = FavoriteStatus.initial,
    this.favoriteIds = const {},
    this.errorMessage = '',
    this.syncCount = 0,
  });

  final FavoriteStatus status;
  final Set<String> favoriteIds;

  /// Translation key for the snackbar shown when a toggle fails.
  final String errorMessage;

  /// Incremented every time a toggle has been persisted to the backend.
  ///
  /// [favoriteIds] changes optimistically *before* the write completes, so
  /// refetching consumers must listen to this counter instead.
  final int syncCount;

  /// Whether the lesson with [lessonId] is currently a favorite.
  bool isFavorite(String lessonId) => favoriteIds.contains(lessonId);

  @override
  List<Object?> get props => [status, favoriteIds, errorMessage, syncCount];

  FavoriteState copyWith({
    FavoriteStatus? status,
    Set<String>? favoriteIds,
    String? errorMessage,
    int? syncCount,
  }) {
    return FavoriteState(
      status: status ?? this.status,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      errorMessage: errorMessage ?? this.errorMessage,
      syncCount: syncCount ?? this.syncCount,
    );
  }
}
