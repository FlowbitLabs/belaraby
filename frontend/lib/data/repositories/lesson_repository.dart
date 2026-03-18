import 'package:belaraby/data/models/lesson_model.dart';
import 'package:belaraby/data/supabase_client.dart';
import 'package:flutter/foundation.dart';

/// Repository for managing [Lesson] data.
///
/// Handles interactions with Supabase tables:
/// - `lessons`: Main lesson content.
/// - `user_favorites`: User's favorite lessons.
/// - `user_learned_lessons`: User's completed lessons.
class LessonRepository {
  Future<List<Lesson>> getAllLessons() async {
    return await supabase
        .from('lessons')
        .select()
        .order('created_at', ascending: false)
        .withConverter((data) => data.map(Lesson.fromJson).toList());
  }

  Future<List<Lesson>> getFavoriteLessons({required String userId}) async {
    return await supabase
        .from('user_favorites')
        .select('lesson_id, lessons(*)')
        .eq('user_id', userId)
        .withConverter((data) {
          return data.map((json) {
            final lessonData = json['lessons'] as Map<String, dynamic>;
            return Lesson.fromJson(lessonData);
          }).toList();
        });
  }

  Future<List<Lesson>> getLearnedLessons({required String userId}) async {
    return await supabase
        .from('user_learned_lessons')
        .select('lesson_id, lessons(*)')
        .eq('user_id', userId)
        .withConverter((data) {
          return data.map((json) {
            final lessonData = json['lessons'] as Map<String, dynamic>;
            return Lesson.fromJson(lessonData);
          }).toList();
        });
  }

  Future<bool> toggleFavoriteLesson({
    required String userId,
    required String lessonId,
  }) =>
      _toggleUserLesson(
        table: 'user_favorites',
        userId: userId,
        lessonId: lessonId,
      );

  Future<bool> toggleLearnedLesson({
    required String userId,
    required String lessonId,
  }) =>
      _toggleUserLesson(
        table: 'user_learned_lessons',
        userId: userId,
        lessonId: lessonId,
      );

  Future<Lesson?> getLessonById(String id) async {
    return await supabase
        .from('lessons')
        .select()
        .eq('id', id)
        .maybeSingle()
        .withConverter(
          (data) => data != null ? Lesson.fromJson(data) : null,
        );
  }

  Future<bool> _toggleUserLesson({
    required String table,
    required String userId,
    required String lessonId,
  }) async {
    try {
      final existing = await supabase
          .from(table)
          .select('user_id')
          .eq('user_id', userId)
          .eq('lesson_id', lessonId)
          .maybeSingle();

      if (existing != null) {
        await supabase
            .from(table)
            .delete()
            .eq('user_id', userId)
            .eq('lesson_id', lessonId);
      } else {
        await supabase
            .from(table)
            .insert({'user_id': userId, 'lesson_id': lessonId});
      }
      return true;
    } catch (e, st) {
      debugPrint('[$table] toggleUserLesson error: $e\n$st');
      return false;
    }
  }
}
