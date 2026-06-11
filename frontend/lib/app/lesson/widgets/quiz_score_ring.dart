import 'package:belaraby/app/util/convert_arabic_digits.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:flutter/material.dart';

/// Circular correct/total score, mirroring the hero progress ring style.
class QuizScoreRing extends StatelessWidget {
  const QuizScoreRing({
    required this.correctCount,
    required this.totalCount,
    super.key,
  });

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
              backgroundColor: Colors.white24,
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
              '${convertToArabicDigits(number: correctCount)}/'
              '${convertToArabicDigits(number: totalCount)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
