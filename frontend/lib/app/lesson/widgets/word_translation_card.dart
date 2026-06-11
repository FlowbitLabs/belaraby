import 'package:belaraby/app/lesson/utils/word_speaker.dart';
import 'package:belaraby/app/practice/cubit/practice_cubit.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/constant/typography.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Floating card showing the tapped word with its English translation.
class WordTranslationCard extends StatelessWidget {
  const WordTranslationCard({
    required this.word,
    required this.translatedText,
    required this.isTranslating,
    required this.errorMessage,
    required this.onDismissed,
    super.key,
  });

  final String word;
  final String? translatedText;
  final bool isTranslating;
  final String? errorMessage;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(word),
      onDismissed: (_) => onDismissed(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: grey110),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word,
                    textAlign: TextAlign.start,
                    style: BTextStyles.of(context).title1.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  _TranslationStatusLine(
                    translatedText: translatedText,
                    isTranslating: isTranslating,
                    errorMessage: errorMessage,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.volume_up, size: 20),
              tooltip: 'tooltip_play'.tr(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onPressed: () => WordSpeaker().speak(word),
            ),
            // Add the tapped story word to the practice deck (stored on
            // this device; the translation becomes the card meaning).
            Builder(
              builder: (context) {
                final isInPractice = context.select(
                  (PracticeCubit cubit) =>
                      cubit.state.customWords.contains(word),
                );
                return IconButton(
                  icon: Icon(
                    isInPractice
                        ? Icons.bookmark_added
                        : Icons.bookmark_add_outlined,
                    size: 20,
                    color: isInPractice ? green115 : grey160,
                  ),
                  tooltip: isInPractice
                      ? 'practice_remove_tooltip'.tr()
                      : 'practice_add_tooltip'.tr(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  onPressed: () => context
                      .read<PracticeCubit>()
                      .toggleCustomWord(word, translatedText ?? ''),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Result line of the word translation: the translated text, a progress
/// indicator while translating, or the error message.
class _TranslationStatusLine extends StatelessWidget {
  const _TranslationStatusLine({
    required this.translatedText,
    required this.isTranslating,
    required this.errorMessage,
  });

  final String? translatedText;
  final bool isTranslating;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (translatedText != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          translatedText!,
          style: BTextStyles.of(context).body1.copyWith(
            color: Colors.blue.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    if (isTranslating) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 1.5),
            ),
            const SizedBox(width: 6),
            Text(
              'translating'.tr(),
              style: BTextStyles.of(
                context,
              ).caption.copyWith(color: grey160),
            ),
          ],
        ),
      );
    }
    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            const Icon(Icons.error_outline, size: 12, color: red130),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                errorMessage!,
                style: BTextStyles.of(
                  context,
                ).caption.copyWith(color: red130),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
