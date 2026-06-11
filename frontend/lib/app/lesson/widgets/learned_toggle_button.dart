import 'package:belaraby/app/lesson/cubit/learned_cubit.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Marks the lesson as learned (or unlearned) via the global [LearnedCubit];
/// failures surface as a snackbar after the optimistic toggle is reverted.
class LearnedToggleButton extends StatelessWidget {
  const LearnedToggleButton({required this.lessonId, super.key});

  final String lessonId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LearnedCubit, LearnedState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage.isNotEmpty,
      listener: (context, learnedState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(learnedState.errorMessage.tr())),
        );
      },
      builder: (context, learnedState) {
        final isLearnt = learnedState.isLearned(lessonId);
        // Learnt = success green, not-yet = neutral white pill on the hero
        // photo. AnimatedContainer makes the toggle feel responsive.
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: () => context.read<LearnedCubit>().toggleLearned(lessonId),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isLearnt
                    ? green115
                    : Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(100),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              // RTL: the icon is the LAST child so the checkmark renders
              // on the left of the label.
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'lesson_learnt_button'.tr(),
                    style: TextStyle(
                      color: isLearnt ? Colors.white : grey180,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      height: 1,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    isLearnt ? Icons.check_circle : Icons.check_circle_outline,
                    color: isLearnt ? Colors.white : grey160,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
