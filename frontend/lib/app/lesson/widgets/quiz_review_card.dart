import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/constant/typography.dart';
import 'package:belaraby/data/models/lesson_exercise_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// One reviewed question: result icon, question text and — when answered
/// wrong — the user's answer next to the correct one.
class QuizReviewCard extends StatelessWidget {
  const QuizReviewCard({
    required this.exercise,
    required this.selectedOptionId,
    super.key,
  });

  final LessonExercise exercise;
  final String? selectedOptionId;

  bool get _isCorrect => exercise.options.any(
    (option) => option.id == selectedOptionId && option.isCorrect,
  );

  String get _correctAnswerText => exercise.options
      .firstWhere(
        (option) => option.isCorrect,
        orElse: () => exercise.options.first,
      )
      .optionText;

  String get _selectedAnswerText => exercise.options
      .firstWhere(
        (option) => option.id == selectedOptionId,
        orElse: () => exercise.options.first,
      )
      .optionText;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: _isCorrect ? green50 : red30,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 10, top: 2),
              child: Icon(
                _isCorrect ? Icons.check_circle : Icons.cancel,
                color: _isCorrect ? green115 : red110,
                size: 22,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.question,
                    style: BTextStyles.of(context).body1.copyWith(
                      color: grey190,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'quiz_your_answer'.tr(args: [_selectedAnswerText]),
                    style: BTextStyles.of(context).body1.copyWith(
                      color: _isCorrect ? green140 : red110,
                      fontSize: 14,
                    ),
                  ),
                  if (!_isCorrect) ...[
                    const SizedBox(height: 2),
                    Text(
                      'quiz_correct_answer'.tr(args: [_correctAnswerText]),
                      style: BTextStyles.of(context).body1.copyWith(
                        color: green140,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
