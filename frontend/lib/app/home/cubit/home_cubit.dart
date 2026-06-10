import 'package:belaraby/app/home/cubit/home_state.dart';
import 'package:belaraby/data/data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum HomeStatus { initial, loading, success, error }

/// Cubit for the home screen: the lesson list and its filters.
///
/// Emits `loading` while fetching, then `success` with the lessons or
/// `error` with a message. Filter changes ([filterBy], [toggleHideLearned],
/// [updateLearnedIds]) only update the filter fields — the actual filtering
/// happens in [HomeState.paidLessonsBySelectedLevel].
class HomeCubit extends Cubit<HomeState> {
  HomeCubit({LessonRepository? repository})
    : _repository = repository ?? LessonRepository(),
      super(const HomeState());

  final LessonRepository _repository;

  /// Selects a level filter by its translation key.
  void filterBy(String levelKey) {
    emit(state.copyWith(filterBy: levelKey));
  }

  /// Shows or hides the lessons the user already marked as learned.
  void toggleHideLearned() {
    emit(state.copyWith(hideLearned: !state.hideLearned));
  }

  /// Mirrors the learned lesson ids from the global `LearnedCubit`.
  void updateLearnedIds(Set<String> learnedIds) {
    emit(state.copyWith(learnedIds: learnedIds));
  }

  /// Loads all lessons from the backend.
  Future<void> getLessons() async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final lessons = await _repository.getAllLessons();
      emit(state.copyWith(status: HomeStatus.success, lessons: lessons));
    } on Exception catch (e) {
      emit(state.copyWith(status: HomeStatus.error, error: e.toString()));
    }
  }

  /// Refetches the lessons right after a purchase.
  ///
  /// Story bodies stay masked server-side until the RevenueCat webhook
  /// lands, so this retries with bounded backoff (~10s) until no paid body
  /// is masked anymore, then emits whatever the last fetch returned. The
  /// current list stays visible during the retries.
  Future<void> getLessonsAfterPurchase() async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final lessons = await _repository.getAllLessonsUnlocked();
      emit(state.copyWith(status: HomeStatus.success, lessons: lessons));
    } on Exception catch (e) {
      emit(state.copyWith(status: HomeStatus.error, error: e.toString()));
    }
  }
}
