import 'package:belaraby/app/lesson/widgets/lesson_controls.dart';
import 'package:belaraby/constant/typography.dart';
import 'package:belaraby/data/data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

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
        final cleanedSelected = widget.selectedWord?.replaceAll(RegExp(r'[,.!?;:،؛]'), '') ?? '';
        
        final isSelected = widget.selectedWord != null && 
                          cleanedText.isNotEmpty && 
                          cleanedText == cleanedSelected;
        
        return TextSpan(
          text: text,
          style: span.style?.copyWith(
            backgroundColor: isSelected ? Colors.blue.withOpacity(0.3) : span.style?.backgroundColor,
            fontWeight: isSelected ? FontWeight.bold : span.style?.fontWeight,
          ),
          children: span.children?.map((child) => _processTextSpan(child)).toList(),
        );
      }
      
      // If no text, process children
      if (span.children != null) {
        return TextSpan(
          style: span.style,
          children: span.children!.map((child) => _processTextSpan(child)).toList(),
        );
      }
      
      return span;
    }
    
    return span;
  }

  bool _isWordBoundary(String char) {
    return char == ' ' || char == '\n' || char == '\t' || char == '\r';
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
                style: BTextStyles.of(context).displayLarge.copyWith(fontWeight: FontWeight.bold),
              ),
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
                    style: BTextStyles.of(context).h1.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final textSpan = _buildTextSpanWithSelection();
                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTapUp: (details) {
                      // Create text painter with exact same constraints as the rendered text
                      final textPainter = TextPainter(
                        text: textSpan,
                        textDirection: Directionality.of(context),
                      );
                      textPainter.layout(maxWidth: constraints.maxWidth);
                      
                      // Use the tap position directly
                      final tapPosition = details.localPosition;
                      
                      // Get the character position in the text
                      final position = textPainter.getPositionForOffset(tapPosition);
                      
                      // Use TextPainter's built-in word boundary detection
                      final wordBoundary = textPainter.getWordBoundary(position);
                      
                      // Extract the word from the TextSpan's plain text
                      final plainText = textSpan.toPlainText();
                      
                      if (wordBoundary.start >= 0 && wordBoundary.end <= plainText.length) {
                        final word = plainText.substring(wordBoundary.start, wordBoundary.end).trim();
                        // Remove common punctuation from the selected word for consistent matching
                        final cleanedWord = word.replaceAll(RegExp(r'[,.!?;:،؛]'), '');
                        if (cleanedWord.isNotEmpty) {
                          widget.onWordSelected(cleanedWord);
                        }
                      }
                    },
                    child: RichText(
                      text: textSpan,
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
}
