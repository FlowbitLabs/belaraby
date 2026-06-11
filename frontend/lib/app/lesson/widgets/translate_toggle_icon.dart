import 'package:belaraby/constant/colors.dart';
import 'package:flutter/material.dart';

/// Icon switching between the Arabic story and the sentence-by-sentence
/// translated view.
class TranslateToggleIcon extends StatelessWidget {
  const TranslateToggleIcon({
    required this.isTranslated,
    required this.onTap,
    super.key,
  });

  final bool isTranslated;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        Icons.translate,
        color: isTranslated ? navy110 : grey140,
        size: 30,
      ),
    );
  }
}
