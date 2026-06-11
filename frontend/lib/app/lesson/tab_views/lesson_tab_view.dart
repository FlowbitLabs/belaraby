import 'dart:ui' as ui;

import 'package:belaraby/app/lesson/cubit/favorite_cubit.dart';
import 'package:belaraby/app/lesson/utils/translation_helper.dart';
import 'package:belaraby/app/lesson/widgets/lesson_controls.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/constant/typography.dart';
import 'package:belaraby/data/data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Punctuation stripped from tapped words so taps on "كلمة،" still match
/// and translate "كلمة".
final RegExp _wordPunctuation = RegExp('[,.!?;:،؛]');

/// Extracts the tapped word from [textPainter]'s laid-out text.
///
/// Returns `null` when the tap does not resolve to a word (e.g. taps on
/// whitespace or outside the text bounds).
String? _wordAtTapPosition(TextPainter textPainter, Offset tapPosition) {
  final position = textPainter.getPositionForOffset(tapPosition);
  final wordBoundary = textPainter.getWordBoundary(position);
  final plainText = textPainter.text!.toPlainText();
  if (wordBoundary.start < 0 || wordBoundary.end > plainText.length) {
    return null;
  }
  final word = plainText
      .substring(wordBoundary.start, wordBoundary.end)
      .trim()
      .replaceAll(_wordPunctuation, '');
  return word.isEmpty ? null : word;
}

/// Story tab of a lesson: title, favorite/translate actions, the tappable
/// story text (with karaoke highlighting driven by the parent) and the
/// playback controls.
class LessonTabView extends StatefulWidget {
  const LessonTabView({
    required this.lesson,
    required this.textSpan,
    required this.speak,
    required this.stop,
    required this.isPlaying,
    required this.isRepeatEnabled,
    required this.onRepeatToggle,
    required this.onWordSelected,
    required this.selectedWord,
    super.key,
  });

  final Lesson lesson;
  final TextSpan textSpan;
  final Future<void> Function() speak;
  final Future<void> Function() stop;
  final bool isPlaying;
  final bool isRepeatEnabled;
  final VoidCallback onRepeatToggle;
  final void Function(String) onWordSelected;
  final String? selectedWord;

  @override
  State<LessonTabView> createState() => _LessonTabViewState();
}

class _LessonTabViewState extends State<LessonTabView> {
  bool _isTranslated = false;
  final Map<String, String> _sentenceTranslations = {};
  bool _isTranslatingAll = false;
  final TranslationHelper _translationHelper = TranslationHelper();

  /// Localized display label for the DB `grade` value (`'1'`–`'4'`).
  ///
  /// Unknown grades fall back to the raw value so newly added grades
  /// degrade gracefully instead of rendering nothing.
  String _levelLabel(String grade) {
    const knownGrades = {'1', '2', '3', '4'};
    return knownGrades.contains(grade) ? 'lesson_level_$grade'.tr() : grade;
  }

  void _toggleTranslated() {
    setState(() {
      _isTranslated = !_isTranslated;
    });
    if (_isTranslated && _sentenceTranslations.isEmpty) {
      _translateAllSentences();
    }
  }

  List<String> _splitIntoSentences(String text) {
    // Split by Arabic and English sentence endings
    final sentences = text.split(RegExp('[.!?؟]'));
    return sentences.map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  Future<void> _translateAllSentences() async {
    if (_isTranslatingAll) return;

    setState(() {
      _isTranslatingAll = true;
    });

    final sentences = _splitIntoSentences(widget.lesson.body);

    for (final sentence in sentences) {
      if (_sentenceTranslations.containsKey(sentence)) continue;

      await _translationHelper.translateWord(
        sentence,
        onLoading: () {},
        onSuccess: (translated) {
          if (mounted) {
            setState(() {
              _sentenceTranslations[sentence] = translated;
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _sentenceTranslations[sentence] = 'translation_error'.tr();
            });
          }
        },
      );
    }

    setState(() {
      _isTranslatingAll = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.lesson.title,
                style: BTextStyles.of(
                  context,
                ).displayLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LessonFavoriteIcon(lessonId: widget.lesson.id),
                  const SizedBox(width: 12),
                  _TranslateToggleIcon(
                    isTranslated: _isTranslated,
                    onTap: _toggleTranslated,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _levelLabel(widget.lesson.grade),
                    style: BTextStyles.of(
                      context,
                    ).h1.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_isTranslated)
                _TranslatedSentencesView(
                  sentences: _splitIntoSentences(widget.lesson.body),
                  translations: _sentenceTranslations,
                  isTranslating: _isTranslatingAll,
                  onWordSelected: widget.onWordSelected,
                )
              else
                _TappableStoryText(
                  textSpan: widget.textSpan,
                  selectedWord: widget.selectedWord,
                  onWordSelected: widget.onWordSelected,
                ),
              const SizedBox(height: 100),
            ],
          ),
        ),
        LessonControls(
          isPlaying: widget.isPlaying,
          onPlay: widget.speak,
          onStop: widget.stop,
          isRepeatEnabled: widget.isRepeatEnabled,
          onRepeatToggle: widget.onRepeatToggle,
        ),
      ],
    );
  }
}

/// Heart icon toggling the lesson in the user's favorites.
class _LessonFavoriteIcon extends StatelessWidget {
  const _LessonFavoriteIcon({required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.select(
      (FavoriteCubit cubit) => cubit.state.isFavorite(lessonId),
    );
    return GestureDetector(
      onTap: () => context.read<FavoriteCubit>().toggleFavorite(lessonId),
      child: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? red110 : grey140,
        size: 30,
      ),
    );
  }
}

/// Icon switching between the Arabic story and the sentence-by-sentence
/// translated view.
class _TranslateToggleIcon extends StatelessWidget {
  const _TranslateToggleIcon({required this.isTranslated, required this.onTap});

  final bool isTranslated;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        Icons.translate,
        color: isTranslated ? purple110 : grey140,
        size: 30,
      ),
    );
  }
}

/// The story text; tapping a word selects it for translation.
///
/// The tap is mapped to a word by laying out a [TextPainter] with exactly
/// the same span, width and strut as the rendered [RichText] — any styling
/// drift between the two breaks the word hit-testing.
class _TappableStoryText extends StatelessWidget {
  const _TappableStoryText({
    required this.textSpan,
    required this.selectedWord,
    required this.onWordSelected,
  });

  static const StrutStyle _strutStyle = StrutStyle(
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
      final cleanedText = text.trim().replaceAll(_wordPunctuation, '');
      final cleanedSelected =
          selectedWord?.replaceAll(_wordPunctuation, '') ?? '';
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
              strutStyle: _strutStyle,
            )..layout(maxWidth: constraints.maxWidth);

            final word = _wordAtTapPosition(
              textPainter,
              details.localPosition,
            );
            if (word != null) onWordSelected(word);
          },
          child: RichText(text: highlightedSpan, strutStyle: _strutStyle),
        );
      },
    );
  }
}

/// Sentence-by-sentence view: each Arabic sentence followed by its English
/// translation (or a spinner while the translation is still loading).
class _TranslatedSentencesView extends StatelessWidget {
  const _TranslatedSentencesView({
    required this.sentences,
    required this.translations,
    required this.isTranslating,
    required this.onWordSelected,
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

    final word = _wordAtTapPosition(textPainter, details.localPosition);
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
