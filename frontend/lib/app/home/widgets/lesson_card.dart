import 'package:belaraby/app/util/convert_arabic_date.dart';
import 'package:belaraby/app/util/get_level_color.dart';
import 'package:belaraby/data/models/lesson_model.dart';
import 'package:flutter/material.dart';

class LessonCard extends StatelessWidget {
  const LessonCard({required this.lesson, super.key});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 400,
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.network(lesson.heroImage, fit: BoxFit.cover),
            ),

            // Overlay content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      lesson.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    // Body
                    Padding(
                      padding: const EdgeInsetsGeometry.only(left: 15),
                      child: Text(
                        lesson.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.black.withAlpha((0.7 * 255).toInt()),
                          fontSize: 18,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Bottom row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Level badge + Date
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: getLevelColor(lesson.level),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                lesson.level,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              formatArabicDate(lesson.date),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        // Favorite icon
                        IconButton(
                          icon: const Icon(Icons.favorite_border),
                          onPressed: () {
                            // TODO: Implement add to favorites
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (lesson.isPaid)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent.withAlpha(150),
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_rounded, size: 20, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
