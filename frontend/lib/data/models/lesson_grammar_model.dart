/// A grammar explanation attached to a lesson (`lesson_grammar` table).
class LessonGrammarItem {
  const LessonGrammarItem({
    required this.id,
    required this.lessonId,
    required this.explanation,
  });

  /// Maps a `lesson_grammar` row to a [LessonGrammarItem].
  factory LessonGrammarItem.fromJson(Map<String, dynamic> json) {
    return LessonGrammarItem(
      id: json['id'] as String,
      lessonId: json['lesson_id'] as String? ?? '',
      explanation: json['explanation'] as String,
    );
  }

  final String id;
  final String lessonId;
  final String explanation;
}
