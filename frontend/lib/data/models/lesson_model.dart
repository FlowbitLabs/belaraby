import 'package:equatable/equatable.dart';

class Lesson extends Equatable {
  const Lesson({
    required this.id,
    required this.isPaid,
    required this.title,
    required this.body,
    required this.level,
    required this.grade,
    required this.heroImage,
    this.date,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      isPaid: json['paid'] as bool,
      title: json['title'] as String,
      body: json['body'] as String,
      level: json['level'] as String,
      grade: json['grade'] as String,
      heroImage: json['hero_image'] as String,
      date: json['date'] as String?,
    );
  }

  final String id;
  final bool isPaid;
  final String title;
  final String body;
  final String level;
  final String grade;
  final String heroImage;
  final String? date;

  @override
  List<Object?> get props => [
    id,
    isPaid,
    title,
    body,
    level,
    grade,
    heroImage,
    date,
  ];

  Lesson copyWith({
    String? id,
    bool? isPaid,
    String? title,
    String? body,
    String? level,
    String? grade,
    String? heroImage,
    String? date,
  }) {
    return Lesson(
      id: id ?? this.id,
      isPaid: isPaid ?? this.isPaid,
      title: title ?? this.title,
      body: body ?? this.body,
      level: level ?? this.level,
      grade: grade ?? this.grade,
      heroImage: heroImage ?? this.heroImage,
      date: date ?? this.date,
    );
  }
}
