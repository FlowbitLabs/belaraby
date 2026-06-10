import 'package:belaraby/data/repositories/library_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum LearnedStatus { initial, loading, success, error }

/// Global cubit holding the ids of the lessons the user marked as learned.
///
/// Mirrors [Set] updates from the per-lesson `LessonCubit` toggle so the
/// home screen "Hide Learned" filter stays in sync without refetching.
class LearnedCubit extends Cubit<LearnedState> {
  LearnedCubit({LibraryRepository? repository})
    : _repository = repository ?? LibraryRepository(),
      super(const LearnedState());

  final LibraryRepository _repository;

  /// Loads the user's learned lesson ids.
  Future<void> loadLearned() async {
    emit(state.copyWith(status: LearnedStatus.loading));
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

  /// Adds or removes [lessonId] locally (no backend call).
  ///
  /// Called when `LessonCubit` toggles the learned status — that cubit owns
  /// the backend write; this only keeps the global id set in sync.
  void setLearned(String lessonId, {required bool isLearned}) {
    final ids = Set<String>.of(state.learnedIds);
    if (isLearned) {
      ids.add(lessonId);
    } else {
      ids.remove(lessonId);
    }
    if (setEquals(ids, state.learnedIds)) return;
    emit(state.copyWith(status: LearnedStatus.success, learnedIds: ids));
  }
}

class LearnedState extends Equatable {
  const LearnedState({
    this.status = LearnedStatus.initial,
    this.learnedIds = const {},
  });

  final LearnedStatus status;
  final Set<String> learnedIds;

  /// Whether the lesson with [lessonId] is marked as learned.
  bool isLearned(String lessonId) => learnedIds.contains(lessonId);

  @override
  List<Object?> get props => [status, learnedIds];

  LearnedState copyWith({LearnedStatus? status, Set<String>? learnedIds}) {
    return LearnedState(
      status: status ?? this.status,
      learnedIds: learnedIds ?? this.learnedIds,
    );
  }
}
