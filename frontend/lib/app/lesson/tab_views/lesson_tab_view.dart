import 'package:belaraby/app/lesson/widgets/lesson_controls.dart';
import 'package:belaraby/constant/typography.dart';
import 'package:belaraby/data/data.dart';
import 'package:flutter/material.dart';

class LessonTabView extends StatefulWidget {
  const LessonTabView({
    required this.lesson,
    required this.textSpan,
    required this.speak,
    required this.stop,
    required this.isPlaying,
    super.key,
  });

  final Lesson lesson;
  final TextSpan textSpan;
  final Future<void> Function() speak;
  final Future<void> Function() stop;
  final bool isPlaying;

  @override
  State<LessonTabView> createState() => _LessonTabViewState();
}

class _LessonTabViewState extends State<LessonTabView> {
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
                style: BTextStyles.of(context).displayMedium,
              ),
              Text(
                widget.lesson.grade,
                style: BTextStyles.of(context).title2,
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
        ),
      ],
    );
  }
}
