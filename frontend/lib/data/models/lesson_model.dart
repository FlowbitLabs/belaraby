class Lesson {
  Lesson({
    required this.isPaid,
    required this.title,
    required this.body,
    required this.level,
    required this.grade,
    required this.heroImage,
    required this.date,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      isPaid: json['paid'] as bool,
      title: json['title'] as String,
      body: json['body'] as String,
      level: json['level'] as String,
      grade: json['grade'] as String,
      heroImage: json['hero_image'] as String,
      date: json['date'] as String?,
    );
  }

  final bool isPaid;
  final String title;
  final String body;
  final String level;
  final String grade;
  final String heroImage;
  final String? date;
}
