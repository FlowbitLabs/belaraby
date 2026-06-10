import 'package:belaraby/data/repositories/library_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum LessonStatus { initial, loading, success, error }

/// Cubit for a single opened lesson: tracks its learned status.
class LessonCubit extends Cubit<LessonState> {
  LessonCubit({required String lessonId, LibraryRepository? repository})
    : _lessonId = lessonId,
      _repository = repository ?? LibraryRepository(),
      super(const LessonState());

  final String _lessonId;
  final LibraryRepository _repository;

  /// Loads whether the lesson is already marked as learned.
  Future<void> loadLearnedStatus() async {
    emit(state.copyWith(status: LessonStatus.loading, errorMessage: ''));
    try {
      final isLearned = await _repository.isLearned(_lessonId);
      emit(
        state.copyWith(status: LessonStatus.success, isLearned: isLearned),
      );
    } on Exception catch (error) {
      debugPrint('LessonCubit.loadLearnedStatus failed: $error');
      emit(state.copyWith(status: LessonStatus.error));
    }
  }

  /// Marks or unmarks the lesson as learned, optimistically.
  Future<void> toggleLearned() async {
    final wasLearned = state.isLearned;
    emit(
      state.copyWith(
        status: LessonStatus.success,
        isLearned: !wasLearned,
        errorMessage: '',
      ),
    );
    try {
      if (wasLearned) {
        await _repository.unmarkLearned(_lessonId);
      } else {
        await _repository.markLearned(_lessonId);
      }
    } on Exception catch (error) {
      debugPrint('LessonCubit.toggleLearned failed: $error');
      emit(
        state.copyWith(
          status: LessonStatus.error,
          isLearned: wasLearned,
          errorMessage: 'learned_update_error',
        ),
      );
    }
  }
}

class LessonState extends Equatable {
  const LessonState({
    this.status = LessonStatus.initial,
    this.isLearned = false,
    this.errorMessage = '',
  });

  final LessonStatus status;
  final bool isLearned;

  /// Translation key for the snackbar shown when a toggle fails.
  final String errorMessage;

  @override
  List<Object?> get props => [status, isLearned, errorMessage];

  LessonState copyWith({
    LessonStatus? status,
    bool? isLearned,
    String? errorMessage,
  }) {
    return LessonState(
      status: status ?? this.status,
      isLearned: isLearned ?? this.isLearned,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
