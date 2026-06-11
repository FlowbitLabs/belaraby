import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// One self-assessment button in the training page's bottom row.
class AssessButton extends StatelessWidget {
  const AssessButton({
    required this.labelKey,
    required this.color,
    required this.onPressed,
    super.key,
  });

  final String labelKey;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: FittedBox(
            child: Text(
              labelKey.tr(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
