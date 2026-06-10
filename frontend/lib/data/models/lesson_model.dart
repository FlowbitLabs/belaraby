import 'package:equatable/equatable.dart';

/// A story lesson row from the public `lessons` view.
///
/// Extends [Equatable] (unlike the other models) because lesson lists are
/// compared structurally inside bloc states.
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

  /// Maps a `lessons` row (snake_case columns) to a [Lesson].
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

  /// Primary key (uuid).
  final String id;

  /// Whether the lesson requires an active premium subscription.
  final bool isPaid;

  /// Story title (Arabic).
  final String title;

  /// Story body; empty when masked server-side (see [isBodyMasked]).
  final String body;

  /// CEFR-style level label shown on cards (e.g. `A1`).
  final String level;

  /// School grade used by the home screen level filter (`'1'`–`'4'`).
  final String grade;

  /// URL of the cover image.
  final String heroImage;

  /// Publication date as an ISO `yyyy-mm-dd` string, when set.
  final String? date;

  /// Whether the story body was masked server-side.
  ///
  /// Paid lessons are served with an empty `body` until the caller has an
  /// active subscription (see the `public.lessons` masking view migration).
  bool get isBodyMasked => isPaid && body.isEmpty;

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
}
