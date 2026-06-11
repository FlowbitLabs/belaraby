import 'package:flutter/rendering.dart';

/// Punctuation stripped from tapped words so taps on "كلمة،" still match
/// and translate "كلمة".
final RegExp wordPunctuation = RegExp('[,.!?;:،؛]');

/// Extracts the tapped word from [textPainter]'s laid-out text.
///
/// Returns `null` when the tap does not resolve to a word (e.g. taps on
/// whitespace or outside the text bounds).
String? wordAtTapPosition(TextPainter textPainter, Offset tapPosition) {
  final position = textPainter.getPositionForOffset(tapPosition);
  final wordBoundary = textPainter.getWordBoundary(position);
  final plainText = textPainter.text!.toPlainText();
  if (wordBoundary.start < 0 || wordBoundary.end > plainText.length) {
    return null;
  }
  final word = plainText
      .substring(wordBoundary.start, wordBoundary.end)
      .trim()
      .replaceAll(wordPunctuation, '');
  return word.isEmpty ? null : word;
}
