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

  String gradeArabic() {
    switch (grade) {
      case '1':
        return 'الأول ابتدائي';
      case '2':
        return 'الثاني ابتدائي';
      case '3':
        return 'الثالث ابتدائي';
      case '4':
        return 'الرابع ابتدائي';
      default:
        return '';
    }
  }
}
