import 'package:belaraby/app/lesson/utils/translation_helper.dart';
import 'package:belaraby/app/lesson/widgets/lesson_controls.dart';
import 'package:belaraby/app/lesson/widgets/lesson_favorite_icon.dart';
import 'package:belaraby/app/lesson/widgets/tappable_story_text.dart';
import 'package:belaraby/app/lesson/widgets/translate_toggle_icon.dart';
import 'package:belaraby/app/lesson/widgets/translated_sentences_view.dart';
import 'package:belaraby/constant/typography.dart';
import 'package:belaraby/data/data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
    required this.speedLabel,
    required this.onSpeedToggle,
    required this.highlightedCharIndex,
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
  final String speedLabel;
  final VoidCallback onSpeedToggle;

  /// Character offset (into the story) of the word being spoken, or -1.
  /// Drives the auto-scroll that keeps the karaoke highlight visible.
  final int highlightedCharIndex;
  final void Function(String) onWordSelected;
  final String? selectedWord;

  @override
  State<LessonTabView> createState() => _LessonTabViewState();
}

class _LessonTabViewState extends State<LessonTabView> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _storyTextKey = GlobalKey();
  bool _isTranslated = false;

  @override
  void didUpdateWidget(covariant LessonTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Follow the karaoke highlight while the story plays (also right after
    // a resume, when the index itself may not have changed).
    final highlightMoved =
        widget.highlightedCharIndex != oldWidget.highlightedCharIndex;
    if (widget.isPlaying &&
        widget.highlightedCharIndex >= 0 &&
        (highlightMoved || !oldWidget.isPlaying)) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollToHighlightedWord(),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Scrolls so the word being spoken sits in the upper third of the
  /// viewport. Small corrections are skipped to avoid jitter.
  void _scrollToHighlightedWord() {
    if (!mounted || _isTranslated || !widget.isPlaying) return;
    final context = _storyTextKey.currentContext;
    if (context == null || !_scrollController.hasClients) return;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    final viewport = RenderAbstractViewport.maybeOf(box);
    if (viewport == null) return;

    // Top of the story text inside the scrollable, then the highlighted
    // word's vertical position inside the text (same span/strut/width as
    // the rendered RichText, so the layout matches).
    final textTop = viewport.getOffsetToReveal(box, 0).offset;
    final painter = TextPainter(
      text: widget.textSpan,
      textDirection: Directionality.of(context),
      strutStyle: TappableStoryText.strutStyle,
    )..layout(maxWidth: box.size.width);
    final caret = painter.getOffsetForCaret(
      TextPosition(offset: widget.highlightedCharIndex),
      Rect.zero,
    );
    painter.dispose();

    final position = _scrollController.position;
    final target = (textTop + caret.dy - position.viewportDimension / 3).clamp(
      0.0,
      position.maxScrollExtent,
    );
    if ((target - position.pixels).abs() < 24) return;
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

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
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.lesson.title,
                style:
                    BTextStyles.of(
                      context,
                    ).displayLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LessonFavoriteIcon(lessonId: widget.lesson.id),
                  const SizedBox(width: 12),
                  TranslateToggleIcon(
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
                TranslatedSentencesView(
                  sentences: _splitIntoSentences(widget.lesson.body),
                  translations: _sentenceTranslations,
                  isTranslating: _isTranslatingAll,
                  onWordSelected: widget.onWordSelected,
                )
              else
                TappableStoryText(
                  key: _storyTextKey,
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
          speedLabel: widget.speedLabel,
          onSpeedToggle: widget.onSpeedToggle,
        ),
      ],
    );
  }
}
