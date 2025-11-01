import 'dart:ui';

import 'package:belaraby/constant/colors.dart';
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
        Positioned(
          bottom: 50,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: grey115.withAlpha(90), // translucent layer
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton.filled(
                          onPressed: widget.stop,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(10),
                            elevation: 2,
                          ),
                          icon: const Icon(Icons.stop, size: 22),
                        ),
                        const SizedBox(width: 16),
                        IconButton.filled(
                          onPressed: widget.speak,
                          style: IconButton.styleFrom(
                            backgroundColor: widget.isPlaying
                                ? Colors.orangeAccent
                                : Colors.green,
                            foregroundColor: Colors.white,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(10),
                            elevation: 2,
                          ),
                          icon: Icon(
                            widget.isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
