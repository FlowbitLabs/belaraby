import 'package:belaraby/app/lesson/cubit/quiz_cubit.dart';
import 'package:belaraby/app/lesson/widgets/lesson_content_status.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/constant/typography.dart';
import 'package:belaraby/data/models/lesson_exercise_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Multiple-choice quiz of the lesson with per-answer feedback.
class QuizTabView extends StatelessWidget {
  const QuizTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizCubit, QuizState>(
      builder: (context, state) {
        if (state.status == QuizStatus.loading ||
            state.status == QuizStatus.initial) {
          return const LessonContentLoading();
        }
        if (state.status == QuizStatus.error) {
          return LessonContentError(
            onRetry: () => context.read<QuizCubit>().loadExercises(),
          );
        }
        if (state.exercises.isEmpty) {
          return const LessonContentEmpty(
            messageKey: 'lesson_quiz_empty',
            icon: Icons.quiz_outlined,
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final exercise in state.exercises)
              _ExerciseCard(
                exercise: exercise,
                selectedOptionId: state.selectedOptionId(exercise.id),
              ),
            if (state.isCompleted)
              _QuizResult(
                correctCount: state.correctCount,
                totalCount: state.exercises.length,
              ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise, required this.selectedOptionId});

  final LessonExercise exercise;
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
            Text(
              exercise.question,
              style: BTextStyles.of(context).title1.copyWith(
                color: grey190,
                fontWeight: FontWeight.bold,
              ),
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
    if (_isSelected) return const Color(0xFFFDEDED);
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

class _QuizResult extends StatelessWidget {
  const _QuizResult({required this.correctCount, required this.totalCount});

  final int correctCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: yellow15,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'quiz_score'.tr(
                args: ['$correctCount', '$totalCount'],
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: grey180,
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => context.read<QuizCubit>().resetAnswers(),
              child: Text(
                'quiz_retake'.tr(),
                style: const TextStyle(
                  color: yellow140,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
