import 'package:belaraby/app/lesson/utils/word_tap.dart';
import 'package:flutter/material.dart';

/// The story text; tapping a word selects it for translation.
///
/// The tap is mapped to a word by laying out a [TextPainter] with exactly
/// the same span, width and strut as the rendered [RichText] — any styling
/// drift between the two breaks the word hit-testing.
class TappableStoryText extends StatelessWidget {
  const TappableStoryText({
    required this.textSpan,
    required this.selectedWord,
    required this.onWordSelected,
    super.key,
  });

  static const StrutStyle strutStyle = StrutStyle(
    fontSize: 20,
    height: 1.5,
    leading: 0.8,
    forceStrutHeight: true,
  );

  final TextSpan textSpan;
  final String? selectedWord;
  final void Function(String) onWordSelected;

  /// Recursively re-styles [span], highlighting the selected word.
  InlineSpan _withSelectionHighlight(InlineSpan span) {
    if (span is! TextSpan) return span;

    if (span.text != null) {
      final text = span.text!;
      // Strip punctuation on both sides so "كلمة،" still matches "كلمة".
      final cleanedText = text.trim().replaceAll(wordPunctuation, '');
      final cleanedSelected =
          selectedWord?.replaceAll(wordPunctuation, '') ?? '';
      final isSelected =
          selectedWord != null &&
          cleanedText.isNotEmpty &&
          cleanedText == cleanedSelected;

      return TextSpan(
        text: text,
        style: span.style?.copyWith(
          backgroundColor: isSelected
              ? Colors.blue.withValues(alpha: 0.3)
              : span.style?.backgroundColor,
          fontWeight: isSelected ? FontWeight.bold : span.style?.fontWeight,
        ),
        children: span.children?.map(_withSelectionHighlight).toList(),
      );
    }

    if (span.children != null) {
      return TextSpan(
        style: span.style,
        children: span.children!.map(_withSelectionHighlight).toList(),
      );
    }

    return span;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final highlightedSpan = _withSelectionHighlight(textSpan) as TextSpan;

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapUp: (details) {
            final textPainter = TextPainter(
              text: highlightedSpan,
              textDirection: Directionality.of(context),
              strutStyle: strutStyle,
            )..layout(maxWidth: constraints.maxWidth);

            final word = wordAtTapPosition(
              textPainter,
              details.localPosition,
            );
            if (word != null) onWordSelected(word);
          },
          child: RichText(text: highlightedSpan, strutStyle: strutStyle),
        );
      },
    );
  }
}
