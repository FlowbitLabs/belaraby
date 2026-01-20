import 'package:belaraby/app/lesson/utils/translation_helper.dart';
import 'package:belaraby/app/lesson/widgets/lesson_controls.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/constant/typography.dart';
import 'package:belaraby/data/data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

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
  String getLocalizedLevel(BuildContext context, String? grade) {
    if (grade == null) return '';
    final locale = context.locale.languageCode;
    switch (grade) {
      case '1':
        return locale == 'ar' ? 'المستوى الأول' : 'Level One';
      case '2':
        return locale == 'ar' ? 'المستوى الثاني' : 'Level Two';
      case '3':
        return locale == 'ar' ? 'المستوى الثالث' : 'Level Three';
      case '4':
        return locale == 'ar' ? 'المستوى الرابع' : 'Level Four';
      default:
        return grade;
    }
  }

  bool _isLiked = false;
  bool _isTranslated = false;
  final Map<String, String> _sentenceTranslations = {};
  bool _isTranslatingAll = false;
  final TranslationHelper _translationHelper = TranslationHelper();

  TextSpan _buildTextSpanWithSelection() {
    // Recursively process the textSpan to add selection highlighting
    return _processTextSpan(widget.textSpan) as TextSpan;
  }

  InlineSpan _processTextSpan(InlineSpan span) {
    if (span is TextSpan) {
      // Check if this span has text
      if (span.text != null) {
        final text = span.text!;
        final trimmedText = text.trim();

        // Check if this word matches the selected word
        // Remove common punctuation for comparison to handle punctuation attached to words
        final cleanedText = trimmedText.replaceAll(RegExp(r'[,.!?;:،؛]'), '');
        final cleanedSelected =
            widget.selectedWord?.replaceAll(RegExp(r'[,.!?;:،؛]'), '') ?? '';

        final isSelected =
            widget.selectedWord != null &&
            cleanedText.isNotEmpty &&
            cleanedText == cleanedSelected;

        return TextSpan(
          text: text,
          style: span.style?.copyWith(
            backgroundColor: isSelected
                ? Colors.blue.withOpacity(0.3)
                : span.style?.backgroundColor,
            fontWeight: isSelected ? FontWeight.bold : span.style?.fontWeight,
          ),
          children: span.children
              ?.map((child) => _processTextSpan(child))
              .toList(),
        );
      }

      // If no text, process children
      if (span.children != null) {
        return TextSpan(
          style: span.style,
          children: span.children!
              .map((child) => _processTextSpan(child))
              .toList(),
        );
      }

      return span;
    }

    return span;
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
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isLiked = !_isLiked;
                      });
                    },
                    child: Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      color: _isLiked ? Colors.red : Colors.grey,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isTranslated = !_isTranslated;
                      });
                      if (_isTranslated && _sentenceTranslations.isEmpty) {
                        _translateAllSentences();
                      }
                    },
                    child: Icon(
                      Icons.translate,
                      color: _isTranslated ? Colors.blueAccent : Colors.grey,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    getLocalizedLevel(context, widget.lesson.grade),
                    style: BTextStyles.of(
                      context,
                    ).h1.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_isTranslated)
                _buildTranslatedView()
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final textSpan = _buildTextSpanWithSelection();
                    // Define consistent text styling properties

                    const strutStyle = StrutStyle(
                      fontSize: 20,
                      height: 1.5,
                      leading: 0.8,
                      forceStrutHeight: true,
                    );

                    return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTapUp: (details) {
                        // Create text painter with exact same constraints and styling as the rendered text
                        final textPainter = TextPainter(
                          text: textSpan,
                          textDirection: Directionality.of(context),

                          strutStyle: strutStyle,
                        );
                        textPainter.layout(maxWidth: constraints.maxWidth);

                        // Use the tap position directly
                        final tapPosition = details.localPosition;

                        // Get the character position in the text
                        final position = textPainter.getPositionForOffset(
                          tapPosition,
                        );

                        // Use TextPainter's built-in word boundary detection
                        final wordBoundary = textPainter.getWordBoundary(
                          position,
                        );

                        // Extract the word from the TextSpan's plain text
                        final plainText = textSpan.toPlainText();

                        if (wordBoundary.start >= 0 &&
                            wordBoundary.end <= plainText.length) {
                          final word = plainText
                              .substring(wordBoundary.start, wordBoundary.end)
                              .trim();
                          // Remove common punctuation from the selected word for consistent matching
                          final cleanedWord = word.replaceAll(
                            RegExp(r'[,.!?;:،؛]'),
                            '',
                          );
                          if (cleanedWord.isNotEmpty) {
                            widget.onWordSelected(cleanedWord);
                          }
                        }
                      },
                      child: RichText(
                        text: textSpan,
                        strutStyle: strutStyle,
                      ),
                    );
                  },
                ),
              const SizedBox(height: 100),
            ],
          ),
        ),
        // Lesson controls
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

  List<String> _splitIntoSentences(String text) {
    // Split by Arabic and English sentence endings
    final sentences = text.split(RegExp(r'[.!?؟]'));
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
              _sentenceTranslations[sentence] = 'Translation failed';
            });
          }
        },
      );
    }

    setState(() {
      _isTranslatingAll = false;
    });
  }

  void _handleWordSelection(String text, TapUpDetails details) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: BTextStyles.of(context).displaySmall.copyWith(
          fontSize: 20,
          height: 1.5,
        ),
      ),
      textDirection: Directionality.of(context),
      textAlign: TextAlign.right,
    );

    // Layout with max width (approximate screen width minus padding)
    textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 40);

    final tapPosition = details.localPosition;
    final position = textPainter.getPositionForOffset(tapPosition);
    final wordBoundary = textPainter.getWordBoundary(position);

    if (wordBoundary.start >= 0 && wordBoundary.end <= text.length) {
      final word = text.substring(wordBoundary.start, wordBoundary.end).trim();
      final cleanedWord = word.replaceAll(RegExp(r'[,.!?;:،؛]'), '');
      if (cleanedWord.isNotEmpty) {
        widget.onWordSelected(cleanedWord);
      }
    }
  }

  Widget _buildTranslatedView() {
    final sentences = _splitIntoSentences(widget.lesson.body);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (_isTranslatingAll)
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
        ...sentences.map((sentence) {
          final translation = _sentenceTranslations[sentence];
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTapUp: (details) {
                    _handleWordSelection(sentence, details);
                  },
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
                      translation,
                      style: BTextStyles.of(context).body1.copyWith(
                        color: Colors.blue.shade700,
                        fontSize: 16,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w500,
                        height: 1.6,
                        letterSpacing: 0.1,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: null,
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
        }),
        const SizedBox(height: 100),
      ],
    );
  }
}
