import 'package:belaraby/data/models/lesson_model.dart';
import 'package:belaraby/data/repositories/lesson_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum LessonUnlockStatus { initial, loading, success, timeout, error }

/// Waits for a just-purchased lesson body to be unlocked server-side.
///
/// Story bodies stay masked until the RevenueCat webhook updates the
/// `subscriptions` table, so right after a purchase the refetched lesson
/// can still be masked. This cubit retries with bounded backoff (~10s) and
/// reports [LessonUnlockStatus.timeout] when the content is still masked,
/// so the UI can offer a manual retry.
class LessonUnlockCubit extends Cubit<LessonUnlockState> {
  LessonUnlockCubit({required Lesson lesson, LessonRepository? repository})
    : _lesson = lesson,
      _repository = repository ?? LessonRepository(),
      super(const LessonUnlockState());

  final Lesson _lesson;
  final LessonRepository _repository;

  /// Polls the lesson until the body is unlocked or the budget runs out.
  Future<void> waitForUnlock() async {
    emit(state.copyWith(status: LessonUnlockStatus.loading));
    try {
      final refreshed = await _repository.getUnlockedLessonById(_lesson.id);
      if (isClosed) return;
      if (refreshed == null) {
        // The lesson disappeared server-side; let the user retry.
        emit(state.copyWith(status: LessonUnlockStatus.error));
        return;
      }
      if (refreshed.isBodyMasked) {
        emit(
          state.copyWith(
            status: LessonUnlockStatus.timeout,
            lesson: refreshed,
          ),
        );
        return;
      }
      emit(
        state.copyWith(status: LessonUnlockStatus.success, lesson: refreshed),
      );
    } on Exception catch (error) {
      debugPrint('LessonUnlockCubit.waitForUnlock failed: $error');
      if (isClosed) return;
      emit(state.copyWith(status: LessonUnlockStatus.error));
    }
  }
}

class LessonUnlockState extends Equatable {
  const LessonUnlockState({
    this.status = LessonUnlockStatus.initial,
    this.lesson,
  });

  final LessonUnlockStatus status;

  /// The latest fetched lesson; unlocked when [status] is `success`.
  final Lesson? lesson;

  @override
  List<Object?> get props => [status, lesson];

  LessonUnlockState copyWith({LessonUnlockStatus? status, Lesson? lesson}) {
    return LessonUnlockState(
      status: status ?? this.status,
      lesson: lesson ?? this.lesson,
    );
  }
}
