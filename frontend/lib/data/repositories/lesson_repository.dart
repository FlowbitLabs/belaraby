import 'package:belaraby/data/models/lesson_model.dart';
import 'package:belaraby/data/supabase_client.dart';

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

  Future<List<Lesson>> getFavoriteLessons({required int userId}) async {
    return await supabase
        .from('user_favorites')
        // Select logic: fetching the join table `user_favorites` AND the related `lessons` data
        // utilizing Supabase's foreign key detection.
        .select('lesson_id, lessons(*)')
        .eq('user_id', userId)
        .withConverter((data) {
          // The query returns nested structure: {lesson_id: ..., lessons: {...}}
          // We need to map the nested 'lessons' object
          return data.map((json) {
            final lessonData = json['lessons'] as Map<String, dynamic>;
            return Lesson.fromJson(lessonData);
          }).toList();
        });
  }

  Future<List<Lesson>> getLearnedLessons({required int userId}) async {
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
    required int userId,
    required int lessonId,
  }) async {
    try {
      final existing = await supabase
          .from('user_favorites')
          .select('id')
          .eq('user_id', userId)
          .eq('lesson_id', lessonId)
          .maybeSingle();

      final table = supabase.from('user_favorites');

      if (existing != null) {
        await table.delete().eq('user_id', userId).eq('lesson_id', lessonId);
      } else {
        await table.insert({'user_id': userId, 'lesson_id': lessonId});
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleLearnedLesson({
    required int userId,
    required int lessonId,
  }) async {
    try {
      final existing = await supabase
          .from('user_learned_lessons')
          .select('id')
          .eq('user_id', userId)
          .eq('lesson_id', lessonId)
          .maybeSingle();

      final table = supabase.from('user_learned_lessons');

      if (existing != null) {
        await table.delete().eq('user_id', userId).eq('lesson_id', lessonId);
      } else {
        await table.insert({'user_id': userId, 'lesson_id': lessonId});
      }
      return true;
    } catch (e) {
      return false;
    }
  }

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
}
