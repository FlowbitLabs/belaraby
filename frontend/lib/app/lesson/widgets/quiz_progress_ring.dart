import 'package:belaraby/app/lesson/cubit/quiz_cubit.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Circular answered/total progress of the lesson quiz.
///
/// Shown centered over the hero image while the quiz tab is active. Renders
/// nothing until the exercises are loaded, and nothing when the lesson has
/// no quiz.
class QuizProgressRing extends StatelessWidget {
  const QuizProgressRing({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizCubit, QuizState>(
      builder: (context, state) {
        if (state.status != QuizStatus.success || state.exercises.isEmpty) {
          return const SizedBox.shrink();
        }
        return Container(
          width: 76,
          height: 76,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            // Dark scrim so the ring reads on any hero photo.
            color: Colors.black.withValues(alpha: 0.45),
            shape: BoxShape.circle,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(end: state.progress),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => CircularProgressIndicator(
                  value: value,
                  strokeWidth: 5,
                  strokeCap: StrokeCap.round,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(yellow100),
                ),
              ),
              Center(
                child: Text(
                  '${state.answeredCount}/${state.exercises.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
