import 'dart:math';

import 'package:belaraby/data/models/lesson_exercise_model.dart';
import 'package:belaraby/data/repositories/lesson_content_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum QuizStatus { initial, loading, success, error }

/// Cubit for the quiz tab of one lesson: loads the multiple-choice
/// exercises and tracks the user's answers.
class QuizCubit extends Cubit<QuizState> {
  QuizCubit({required String lessonId, LessonContentRepository? repository})
    : _lessonId = lessonId,
      _repository = repository ?? LessonContentRepository(),
      super(const QuizState());

  final String _lessonId;
  final LessonContentRepository _repository;
  final Random _random = Random();

  /// Authored data tends to list the correct option first — shuffle every
  /// exercise's options so answer positions carry no signal.
  List<LessonExercise> _shuffled(List<LessonExercise> exercises) => [
    for (final exercise in exercises)
      LessonExercise(
        id: exercise.id,
        lessonId: exercise.lessonId,
        question: exercise.question,
        options: [...exercise.options]..shuffle(_random),
      ),
  ];

  /// Loads the exercises (with their options) of the lesson.
  Future<void> loadExercises() async {
    emit(state.copyWith(status: QuizStatus.loading));
    try {
      final exercises = await _repository.fetchExercises(_lessonId);
      emit(
        state.copyWith(
          status: QuizStatus.success,
          exercises: _shuffled(exercises),
          selectedOptions: const {},
        ),
      );
    } on Exception catch (error) {
      debugPrint('QuizCubit.loadExercises failed: $error');
      emit(state.copyWith(status: QuizStatus.error));
    }
  }

  /// Records the user's answer for [exerciseId].
  ///
  /// Each question can only be answered once; further taps are ignored so
  /// the correct/incorrect feedback stays stable.
  void selectOption(String exerciseId, String optionId) {
    if (state.selectedOptions.containsKey(exerciseId)) return;
    emit(
      state.copyWith(
        selectedOptions: {...state.selectedOptions, exerciseId: optionId},
      ),
    );
  }

  /// Clears all answers (and reshuffles the options) for a fresh retake.
  void resetAnswers() {
    emit(
      state.copyWith(
        exercises: _shuffled(state.exercises),
        selectedOptions: const {},
      ),
    );
  }
}

class QuizState extends Equatable {
  const QuizState({
    this.status = QuizStatus.initial,
    this.exercises = const [],
    this.selectedOptions = const {},
  });

  final QuizStatus status;
  final List<LessonExercise> exercises;

  /// Maps an exercise id to the id of the option the user selected.
  final Map<String, String> selectedOptions;

  /// The option the user selected for [exerciseId], or null when unanswered.
  String? selectedOptionId(String exerciseId) => selectedOptions[exerciseId];

  /// Whether every loaded exercise has been answered.
  bool get isCompleted =>
      exercises.isNotEmpty &&
      exercises.every(
        (exercise) => selectedOptions.containsKey(exercise.id),
      );

  /// Number of exercises the user has answered so far.
  int get answeredCount => exercises
      .where((exercise) => selectedOptions.containsKey(exercise.id))
      .length;

  /// Quiz completion as a 0..1 fraction (0 when no exercises are loaded).
  double get progress =>
      exercises.isEmpty ? 0 : answeredCount / exercises.length;

  /// Number of correctly answered exercises.
  int get correctCount => exercises.where((exercise) {
    final selectedId = selectedOptions[exercise.id];
    if (selectedId == null) return false;
    return exercise.options.any(
      (option) => option.id == selectedId && option.isCorrect,
    );
  }).length;

  @override
  List<Object?> get props => [status, exercises, selectedOptions];

  QuizState copyWith({
    QuizStatus? status,
    List<LessonExercise>? exercises,
    Map<String, String>? selectedOptions,
  }) {
    return QuizState(
      status: status ?? this.status,
      exercises: exercises ?? this.exercises,
      selectedOptions: selectedOptions ?? this.selectedOptions,
    );
  }
}
