import 'package:belaraby/data/repositories/library_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum LearnedStatus { initial, loading, success, error }

/// Global cubit holding the ids of the lessons the user marked as learned.
///
/// Single source of truth for learned state: the lesson page button, the
/// home screen "Hide Learned" filter and My Library all read this set.
/// Toggles are optimistic: the UI updates immediately and reverts (with an
/// error message) when the backend call fails.
class LearnedCubit extends Cubit<LearnedState> {
  LearnedCubit({LibraryRepository? repository})
    : _repository = repository ?? LibraryRepository(),
      super(const LearnedState());

  final LibraryRepository _repository;

  /// Loads the user's learned lesson ids.
  Future<void> loadLearned() async {
    emit(state.copyWith(status: LearnedStatus.loading, errorMessage: ''));
    try {
      final learned = await _repository.fetchLearned();
      emit(
        state.copyWith(
          status: LearnedStatus.success,
          learnedIds: learned.map((lesson) => lesson.id).toSet(),
        ),
      );
    } on Exception catch (error) {
      debugPrint('LearnedCubit.loadLearned failed: $error');
      emit(state.copyWith(status: LearnedStatus.error));
    }
  }

  /// Marks or unmarks [lessonId] as learned, optimistically.
  Future<void> toggleLearned(String lessonId) async {
    final previousIds = state.learnedIds;
    final wasLearned = previousIds.contains(lessonId);
    final optimisticIds = Set<String>.of(previousIds);
    if (wasLearned) {
      optimisticIds.remove(lessonId);
    } else {
      optimisticIds.add(lessonId);
    }
    emit(
      state.copyWith(
        status: LearnedStatus.success,
        learnedIds: optimisticIds,
        errorMessage: '',
      ),
    );
    try {
      if (wasLearned) {
        await _repository.unmarkLearned(lessonId);
      } else {
        await _repository.markLearned(lessonId);
      }
      // Signal that the backend write settled: listeners that refetch the
      // learned list (e.g. My Library) must key off [LearnedState.syncCount],
      // not the optimistic id change, or their GET races the write.
      emit(state.copyWith(syncCount: state.syncCount + 1));
    } on Exception catch (error) {
      debugPrint('LearnedCubit.toggleLearned failed: $error');
      emit(
        state.copyWith(
          status: LearnedStatus.error,
          learnedIds: previousIds,
          errorMessage: 'learned_update_error',
        ),
      );
    }
  }
}

class LearnedState extends Equatable {
  const LearnedState({
    this.status = LearnedStatus.initial,
    this.learnedIds = const {},
    this.errorMessage = '',
    this.syncCount = 0,
  });

  final LearnedStatus status;
  final Set<String> learnedIds;

  /// Translation key for the snackbar shown when a toggle fails.
  final String errorMessage;

  /// Incremented every time a toggle has been persisted to the backend.
  ///
  /// [learnedIds] changes optimistically *before* the write completes, so
  /// refetching consumers must listen to this counter instead.
  final int syncCount;

  /// Whether the lesson with [lessonId] is marked as learned.
  bool isLearned(String lessonId) => learnedIds.contains(lessonId);

  @override
  List<Object?> get props => [status, learnedIds, errorMessage, syncCount];

  LearnedState copyWith({
    LearnedStatus? status,
    Set<String>? learnedIds,
    String? errorMessage,
    int? syncCount,
  }) {
    return LearnedState(
      status: status ?? this.status,
      learnedIds: learnedIds ?? this.learnedIds,
      errorMessage: errorMessage ?? this.errorMessage,
      syncCount: syncCount ?? this.syncCount,
    );
  }
}
