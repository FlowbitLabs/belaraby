/// A multiple-choice quiz question of a lesson (`lesson_exercises` table).
class LessonExercise {
  const LessonExercise({
    required this.id,
    required this.lessonId,
    required this.question,
    this.options = const [],
  });

  /// Maps a `lesson_exercises` row to a [LessonExercise]; nested
  /// `lesson_exercise_options` rows are parsed when the query joins them.
  factory LessonExercise.fromJson(Map<String, dynamic> json) {
    return LessonExercise(
      id: json['id'] as String,
      lessonId: json['lesson_id'] as String? ?? '',
      question: json['question'] as String,
      options: (json['lesson_exercise_options'] as List<dynamic>? ?? const [])
          .map(
            (option) =>
                LessonExerciseOption.fromJson(option as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final String id;
  final String lessonId;
  final String question;

  /// The answer options, present when the query joins
  /// `lesson_exercise_options`.
  final List<LessonExerciseOption> options;
}

/// One answer option of a quiz question (`lesson_exercise_options` table).
class LessonExerciseOption {
  const LessonExerciseOption({
    required this.id,
    required this.exerciseId,
    required this.optionText,
    required this.isCorrect,
  });

  /// Maps a `lesson_exercise_options` row to a [LessonExerciseOption].
  factory LessonExerciseOption.fromJson(Map<String, dynamic> json) {
    return LessonExerciseOption(
      id: json['id'] as String,
      exerciseId: json['exercise_id'] as String? ?? '',
      optionText: json['option_text'] as String,
      isCorrect: json['is_correct'] as bool? ?? false,
    );
  }

  final String id;
  final String exerciseId;
  final String optionText;
  final bool isCorrect;
}
