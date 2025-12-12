import 'package:belaraby/app/home/widgets/lesson_card.dart';
import 'package:belaraby/app/router.dart';
import 'package:belaraby/data/models/lesson_model.dart';
import 'package:flutter/material.dart';

class LessonsSection extends StatelessWidget {
  const LessonsSection({required this.lessons, super.key});

  final List<Lesson> lessons;

  @override
  Widget build(BuildContext context) {
    if (lessons.isEmpty) {
      return const Center(
        child: Text(
          'No lessons available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            // Navigate to lesson
            navigateToLesson(context, lessons[index]);
          },
          child: LessonCard(lesson: lessons[index]),
        );
      },
    );
  }
}

