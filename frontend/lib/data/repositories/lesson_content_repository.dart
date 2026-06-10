import 'package:belaraby/data/models/lesson_exercise_model.dart';
import 'package:belaraby/data/models/lesson_grammar_model.dart';
import 'package:belaraby/data/models/lesson_keyword_model.dart';
import 'package:belaraby/data/supabase_client.dart';

/// Repository for the per-lesson learning content: quiz exercises (with
/// their answer options), keywords and grammar explanations.
class LessonContentRepository {
  /// Returns the quiz exercises of the lesson, options included.
  Future<List<LessonExercise>> fetchExercises(String lessonId) async {
    return supabase
        .from('lesson_exercises')
        .select('*, lesson_exercise_options(*)')
        .eq('lesson_id', lessonId)
        .withConverter((data) => data.map(LessonExercise.fromJson).toList());
  }

  /// Returns the keywords of the lesson.
  Future<List<LessonKeyword>> fetchKeywords(String lessonId) async {
    return supabase
        .from('lesson_keywords')
        .select()
        .eq('lesson_id', lessonId)
        .withConverter((data) => data.map(LessonKeyword.fromJson).toList());
  }

  /// Returns the grammar explanations of the lesson.
  Future<List<LessonGrammarItem>> fetchGrammar(String lessonId) async {
    return supabase
        .from('lesson_grammar')
        .select()
        .eq('lesson_id', lessonId)
        .withConverter((data) => data.map(LessonGrammarItem.fromJson).toList());
  }
}
