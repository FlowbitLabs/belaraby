import 'package:belaraby/data/models/lesson_model.dart';
import 'package:belaraby/data/supabase_client.dart';

class LessonRepository {
  Future<List<Lesson>> getAllLessons() async {
    final response = await supabase
        .from('lessons')
        .select()
        .order('created_at', ascending: false);

    if (response.isEmpty) return [];

    return response.map((lesson) {
      return Lesson.fromJson(lesson);
    }).toList();
  }

  Future<List<Lesson>> getFavoriteLessons({required int userId}) async {
    final response = await supabase
        .from('user_favorites')
        .select('lesson_id, lessons(*)')
        .eq('user_id', userId);

    if (response.isEmpty) return [];

    return response.map((lesson) {
      return Lesson.fromJson(lesson);
    }).toList();
  }

  Future<List<Lesson>> getLearnedLessons({required int userId}) async {
    final response = await supabase
        .from('user_learned_lessons')
        .select('lesson_id, lessons(*)')
        .eq('user_id', userId);

    if (response.isEmpty) return [];

    return response.map((lesson) {
      return Lesson.fromJson(lesson);
    }).toList();
  }

  Future<bool> toggleFavoriteLesson({
    required int userId,
    required int lessonId,
  }) async {
    final existing = await supabase
        .from('user_favorites')
        .select('id')
        .eq('user_id', userId)
        .eq('lesson_id', lessonId)
        .maybeSingle();

    final table = supabase.from('user_favorites');

    final response = existing != null
        ? await table.delete().eq('user_id', userId).eq('lesson_id', lessonId)
        : await table.insert({'user_id': userId, 'lesson_id': lessonId});

    return response.error == null;
  }

  Future<bool> toggleLearnedLesson({
    required int userId,
    required int lessonId,
  }) async {
    final existing = await supabase
        .from('user_learned_lessons')
        .select('id')
        .eq('user_id', userId)
        .eq('lesson_id', lessonId)
        .maybeSingle();

    final table = supabase.from('user_learned_lessons');

    final response = existing != null
        ? await table.delete().eq('user_id', userId).eq('lesson_id', lessonId)
        : await table.insert({'user_id': userId, 'lesson_id': lessonId});

    return response.error == null;
  }

  Future<Lesson?> getLessonById(String id) async {
    final response = await supabase
        .from('lessons')
        .select()
        .eq('id', id)
        .maybeSingle();

    return response != null ? Lesson.fromJson(response) : null;
  }
}
