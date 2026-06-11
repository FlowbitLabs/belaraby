import 'package:belaraby/app/lesson/cubit/quiz_cubit.dart';
import 'package:belaraby/app/lesson/widgets/lesson_content_status.dart';
import 'package:belaraby/app/lesson/widgets/quiz_exercise_card.dart';
import 'package:belaraby/app/lesson/widgets/quiz_summary.dart';
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
          return QuizSummary(state: state);
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final (index, exercise) in state.exercises.indexed)
              QuizExerciseCard(
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
