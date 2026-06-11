import 'package:belaraby/app/lesson/cubit/quiz_cubit.dart';
import 'package:belaraby/app/lesson/widgets/quiz_review_card.dart';
import 'package:belaraby/app/lesson/widgets/quiz_score_ring.dart';
import 'package:belaraby/app/util/convert_arabic_digits.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/constant/typography.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Post-quiz summary: overall score ring, a per-question review (with the
/// correct answer spelled out under wrongly answered questions) and a
/// retake button that clears the answers.
class QuizSummary extends StatelessWidget {
  const QuizSummary({required this.state, super.key});

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
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [navy140, navy110],
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Text(
                  _resultMessageKey.tr(),
                  style: BTextStyles.of(context).title1.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                QuizScoreRing(correctCount: correct, totalCount: total),
                const SizedBox(height: 16),
                Text(
                  'quiz_score'.tr(
                    args: [
                      convertToArabicDigits(number: correct),
                      convertToArabicDigits(number: total),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
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
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
          child: Text(
            'quiz_review_title'.tr(),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: grey190,
            ),
          ),
        ),
        for (final exercise in state.exercises)
          QuizReviewCard(
            exercise: exercise,
            selectedOptionId: state.selectedOptionId(exercise.id),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}
