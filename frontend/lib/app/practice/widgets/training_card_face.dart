import 'package:flutter/material.dart';

/// One face of the training flashcard: rounded, shadowed container.
class TrainingCardFace extends StatelessWidget {
  const TrainingCardFace({
    required this.background,
    required this.child,
    super.key,
  });

  final Color background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
