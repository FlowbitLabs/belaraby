import 'package:belaraby/constant/colors.dart';
import 'package:flutter/material.dart';

/// Hero photo of the lesson, shared with the library card via a [Hero] tag.
class LessonHeroImage extends StatelessWidget {
  const LessonHeroImage({required this.imageUrl, super.key});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'lessonImage-$imageUrl',
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const ColoredBox(color: grey140),
      ),
    );
  }
}
