import 'package:belaraby/app/lesson/cubit/quiz_cubit.dart';
import 'package:belaraby/app/util/convert_arabic_digits.dart';
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

  /// "answered/total" with Arabic-Indic digits.
  static String _progressLabel(QuizState state) {
    final answered = convertToArabicDigits(number: state.answeredCount);
    final total = convertToArabicDigits(number: state.exercises.length);
    return '$answered/$total';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizCubit, QuizState>(
      builder: (context, state) {
        if (state.status != QuizStatus.success || state.exercises.isEmpty) {
          return const SizedBox.shrink();
        }
        // Sits on the solid quiz backdrop of the hero section (no scrim
        // needed — the backdrop already guarantees contrast).
        return SizedBox(
          width: 84,
          height: 84,
          child: Stack(
            fit: StackFit.expand,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(end: state.progress),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => CircularProgressIndicator(
                  value: value,
                  strokeWidth: 6,
                  strokeCap: StrokeCap.round,
                  backgroundColor: Colors.white24,
                  // The ring turns green once the quiz is completed.
                  valueColor: AlwaysStoppedAnimation<Color>(
                    state.isCompleted ? green100 : yellow100,
                  ),
                ),
              ),
              Center(
                child: state.isCompleted
                    ? const Icon(
                        Icons.check_rounded,
                        color: green100,
                        size: 36,
                      )
                    : Text(
                        _progressLabel(state),
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
