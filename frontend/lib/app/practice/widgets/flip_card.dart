import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 3D Y-axis flip between [front] and [back], driven by [revealed].
///
/// Shared by the full-screen flashcard training and the mini flashcard
/// preview on the practice list.
class FlipCard extends StatelessWidget {
  const FlipCard({
    required this.revealed,
    required this.front,
    required this.back,
    super.key,
  });

  final bool revealed;
  final Widget front;
  final Widget back;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: revealed ? 1 : 0),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      builder: (context, value, _) {
        final angle = value * math.pi;
        final showBack = angle > math.pi / 2;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: showBack
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(math.pi),
                  child: back,
                )
              : front,
        );
      },
    );
  }
}
