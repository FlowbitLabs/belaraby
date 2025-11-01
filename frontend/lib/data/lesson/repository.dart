import 'package:belaraby/constant/constants.dart';
import 'package:belaraby/data/lesson/model.dart';
import 'package:belaraby/data/supabase_client.dart';

class LessonRepository {
  Future<List<Lesson>> getLessons() async {
    final response = await supabase
        .from(Constants.lessonsTable)
        .select('paid, title, body, level, grade, hero_image, date')
        .order('created_at', ascending: false);

    if (response.isEmpty) return [];

    return response.map((lesson) {
      return Lesson.fromJson(lesson);
    }).toList();
  }

  Future<Lesson?> getLessonById(String id) async {
    final response = await supabase
        .from(Constants.lessonsTable)
        .select('paid, title, body, level, grade, hero_image, date')
        .eq('id', id)
        .maybeSingle();

    return response != null ? Lesson.fromJson(response) : null;
  }
}
