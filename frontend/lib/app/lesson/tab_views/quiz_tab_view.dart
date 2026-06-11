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
        // Once every question is answered the tab becomes a summary page
        // with the score and a per-question review.
        if (state.isCompleted) {
          return _QuizSummary(state: state);
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final (index, exercise) in state.exercises.indexed)
              _ExerciseCard(
                exercise: exercise,
                questionNumber: index + 1,
                totalCount: state.exercises.length,
                selectedOptionId: state.selectedOptionId(exercise.id),
              ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.exercise,
    required this.questionNumber,
    required this.totalCount,
    required this.selectedOptionId,
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
                    color: purple10,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$questionNumber',
                    style: const TextStyle(
                      color: purple140,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
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

/// Post-quiz summary: overall score ring, a per-question review (with the
/// correct answer spelled out under wrongly answered questions) and a
/// retake button that clears the answers.
class _QuizSummary extends StatelessWidget {
  const _QuizSummary({required this.state});

  final QuizState state;

  /// Result message tier: celebrate >=80%, encourage >=50%, console below.
  String get _resultMessageKey {
    final fraction = state.exercises.isEmpty
        ? 0.0
        : state.correctCount / state.exercises.length;
    if (fraction >= 0.8) return 'quiz_result_excellent';
    if (fraction >= 0.5) return 'quiz_result_good';
    return 'quiz_result_poor';
  }

  @override
  Widget build(BuildContext context) {
    final correct = state.correctCount;
    final total = state.exercises.length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          margin: EdgeInsets.zero,
          color: yellow15,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  _resultMessageKey.tr(),
                  style: BTextStyles.of(context).title1.copyWith(
                    color: grey190,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _ScoreRing(correctCount: correct, totalCount: total),
                const SizedBox(height: 16),
                Text(
                  'quiz_score'.tr(args: ['$correct', '$total']),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: grey180,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.read<QuizCubit>().resetAnswers(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: yellow120,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  icon: const Icon(Icons.refresh),
                  label: Text(
                    'quiz_retake'.tr(),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        for (final exercise in state.exercises)
          _ReviewCard(
            exercise: exercise,
            selectedOptionId: state.selectedOptionId(exercise.id),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Circular correct/total score, mirroring the hero progress ring style.
class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.correctCount, required this.totalCount});

  final int correctCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final fraction = totalCount == 0 ? 0.0 : correctCount / totalCount;
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        fit: StackFit.expand,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(end: fraction),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => CircularProgressIndicator(
              value: value,
              strokeWidth: 7,
              strokeCap: StrokeCap.round,
              backgroundColor: grey110,
              valueColor: AlwaysStoppedAnimation<Color>(
                fraction >= 0.8
                    ? green115
                    : fraction >= 0.5
                    ? yellow120
                    : red110,
              ),
            ),
          ),
          Center(
            child: Text(
              '$correctCount/$totalCount',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: grey190,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One reviewed question: result icon, question text and — when answered
/// wrong — the user's answer next to the correct one.
class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.exercise, required this.selectedOptionId});

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
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                  if (!_isCorrect) ...[
                    const SizedBox(height: 6),
                    Text(
                      'quiz_your_answer'.tr(args: [_selectedAnswerText]),
                      style: BTextStyles.of(context).body1.copyWith(
                        color: red110,
                        fontSize: 14,
                      ),
                    ),
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
