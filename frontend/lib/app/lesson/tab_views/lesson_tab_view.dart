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
    super.key,
  });

  final Lesson lesson;
  final TextSpan textSpan;
  final Future<void> Function() speak;
  final Future<void> Function() stop;
  final bool isPlaying;
  final bool isRepeatEnabled;
  final VoidCallback onRepeatToggle;

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
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
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
              RichText(text: widget.textSpan),
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
