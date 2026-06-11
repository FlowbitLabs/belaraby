import 'package:belaraby/app/lesson/cubit/quiz_cubit.dart';
import 'package:belaraby/app/util/convert_arabic_digits.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/constant/typography.dart';
import 'package:belaraby/data/models/lesson_exercise_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// One quiz question card: numbered question text and its tappable options.
class QuizExerciseCard extends StatelessWidget {
  const QuizExerciseCard({
    required this.exercise,
    required this.questionNumber,
    required this.totalCount,
    required this.selectedOptionId,
    super.key,
  });

  final LessonExercise exercise;
  final int questionNumber;
  final int totalCount;
  final String? selectedOptionId;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsetsDirectional.only(end: 10),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: navy10,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    convertToArabicDigits(number: questionNumber),
                    style: const TextStyle(
                      color: navy140,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1,
                      leadingDistribution: TextLeadingDistribution.even,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    exercise.question,
                    style: BTextStyles.of(context).title1.copyWith(
                      color: grey190,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final option in exercise.options)
              _OptionRow(
                option: option,
                exerciseId: exercise.id,
                selectedOptionId: selectedOptionId,
              ),
          ],
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.option,
    required this.exerciseId,
    required this.selectedOptionId,
  });

  final LessonExerciseOption option;
  final String exerciseId;
  final String? selectedOptionId;

  bool get _isAnswered => selectedOptionId != null;
  bool get _isSelected => selectedOptionId == option.id;

  Color get _backgroundColor {
    if (!_isAnswered) return grey100;
    if (option.isCorrect) return green10;
    if (_isSelected) return red10;
    return grey100;
  }

  Color get _borderColor {
    if (!_isAnswered) return grey110;
    if (option.isCorrect) return green115;
    if (_isSelected) return red110;
    return grey110;
  }

  IconData? get _feedbackIcon {
    if (!_isAnswered) return null;
    if (option.isCorrect) return Icons.check_circle;
    if (_isSelected) return Icons.cancel;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: _isAnswered
              ? null
              : () => context.read<QuizCubit>().selectOption(
                  exerciseId,
                  option.id,
                ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: _borderColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    option.optionText,
                    style: BTextStyles.of(
                      context,
                    ).body1.copyWith(color: grey180, fontSize: 16),
                  ),
                ),
                if (_feedbackIcon != null)
                  Icon(
                    _feedbackIcon,
                    size: 20,
                    color: option.isCorrect ? green115 : red110,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
