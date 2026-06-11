import 'dart:ui' as ui;

import 'package:belaraby/app/lesson/utils/word_tap.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/constant/typography.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Sentence-by-sentence view: each Arabic sentence followed by its English
/// translation (or a spinner while the translation is still loading).
class TranslatedSentencesView extends StatelessWidget {
  const TranslatedSentencesView({
    required this.sentences,
    required this.translations,
    required this.isTranslating,
    required this.onWordSelected,
    super.key,
  });

  final List<String> sentences;
  final Map<String, String> translations;
  final bool isTranslating;
  final void Function(String) onWordSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isTranslating)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(
                  'translating'.tr(),
                  style: BTextStyles.of(context).body1.copyWith(
                    color: grey140,
                  ),
                ),
              ],
            ),
          ),
        for (final sentence in sentences)
          _TranslatedSentence(
            sentence: sentence,
            translation: translations[sentence],
            onWordSelected: onWordSelected,
          ),
        const SizedBox(height: 100),
      ],
    );
  }
}

class _TranslatedSentence extends StatelessWidget {
  const _TranslatedSentence({
    required this.sentence,
    required this.translation,
    required this.onWordSelected,
  });

  final String sentence;
  final String? translation;
  final void Function(String) onWordSelected;

  void _handleWordSelection(BuildContext context, TapUpDetails details) {
    final textPainter =
        TextPainter(
            text: TextSpan(
              text: sentence,
              style: BTextStyles.of(context).displaySmall.copyWith(
                fontSize: 20,
                height: 1.5,
              ),
            ),
            textDirection: Directionality.of(context),
            textAlign: TextAlign.right,
          )
          // Layout with max width (approximate screen width minus padding).
          ..layout(maxWidth: MediaQuery.of(context).size.width - 40);

    final word = wordAtTapPosition(textPainter, details.localPosition);
    if (word != null) onWordSelected(word);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          GestureDetector(
            onTapUp: (details) => _handleWordSelection(context, details),
            child: Text(
              sentence,
              style: BTextStyles.of(context).displaySmall.copyWith(
                fontSize: 20,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          if (translation != null)
            Directionality(
              textDirection: ui.TextDirection.ltr,
              child: Text(
                translation!,
                style: BTextStyles.of(context).body1.copyWith(
                  color: Colors.blue.shade700,
                  fontSize: 16,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                  letterSpacing: 0.1,
                ),
                textAlign: TextAlign.center,
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            )
          else
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 1.5),
            ),
        ],
      ),
    );
  }
}
