import 'package:belaraby/constant/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Circular back button overlaid on the lesson hero image.
class LessonBackButton extends StatelessWidget {
  const LessonBackButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(color: grey100, shape: BoxShape.circle),
      child: IconButton(
        // Icons.arrow_back auto-mirrors with the text direction, so it
        // points "back" in both RTL and LTR locales.
        icon: const Icon(Icons.arrow_back, color: grey170, size: 20),
        onPressed: onPressed,
        tooltip: 'tooltip_back'.tr(),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
