/// A keyword (vocabulary item) of a lesson (`lesson_keywords` table).
class LessonKeyword {
  const LessonKeyword({
    required this.id,
    required this.lessonId,
    required this.keyword,
    this.meaning = '',
  });

  /// Maps a `lesson_keywords` row to a [LessonKeyword].
  factory LessonKeyword.fromJson(Map<String, dynamic> json) {
    return LessonKeyword(
      id: json['id'] as String,
      lessonId: json['lesson_id'] as String? ?? '',
      keyword: json['keyword'] as String,
      meaning: json['meaning'] as String? ?? '',
    );
  }

  final String id;
  final String lessonId;
  final String keyword;

  /// Short Arabic explanation shown on the flashcards.
  final String meaning;
}
