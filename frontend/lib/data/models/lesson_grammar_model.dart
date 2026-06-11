/// A grammar explanation attached to a lesson (`lesson_grammar` table).
class LessonGrammarItem {
  const LessonGrammarItem({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.explanation,
    this.example,
  });

  /// Maps a `lesson_grammar` row to a [LessonGrammarItem].
  factory LessonGrammarItem.fromJson(Map<String, dynamic> json) {
    return LessonGrammarItem(
      id: json['id'] as String,
      lessonId: json['lesson_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      explanation: json['explanation'] as String,
      example: json['example'] as String?,
    );
  }

  final String id;
  final String lessonId;

  /// Short heading of the rule; empty on rows authored before the column
  /// existed — the UI hides the heading then.
  final String title;
  final String explanation;

  /// Optional example sentence illustrating the rule.
  final String? example;
}
