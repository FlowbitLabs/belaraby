import 'package:belaraby/data/models/lesson_model.dart';
import 'package:belaraby/data/supabase_client.dart';

/// Repository for managing [Lesson] data.
///
/// Handles interactions with the Supabase `lessons` table. The user's
/// favorites and learned lessons live in `LibraryRepository`.
class LessonRepository {
  LessonRepository({List<Duration>? unlockRetryDelays})
    : _unlockRetryDelays = unlockRetryDelays ?? defaultUnlockRetryDelays;

  /// Backoff schedule used right after a purchase while waiting for the
  /// RevenueCat webhook to activate the subscription server-side
  /// (story bodies stay masked until then). Sums to ~9.5s.
  static const List<Duration> defaultUnlockRetryDelays = [
    Duration(milliseconds: 500),
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 3),
    Duration(seconds: 3),
  ];

  final List<Duration> _unlockRetryDelays;

  /// Returns all lessons, newest first.
  ///
  /// Bodies of paid lessons arrive empty (masked server-side) unless the
  /// caller has an active subscription.
  Future<List<Lesson>> getAllLessons() async {
    return supabase
        .from('lessons')
        .select()
        .order('created_at', ascending: false)
        .withConverter((data) => data.map(Lesson.fromJson).toList());
  }

  /// Returns the lesson with [id], or `null` when it does not exist.
  Future<Lesson?> getLessonById(String id) async {
    return supabase
        .from('lessons')
        .select()
        .eq('id', id)
        .maybeSingle()
        .withConverter((data) => data != null ? Lesson.fromJson(data) : null);
  }

  /// Refetches the lesson until its body is no longer masked server-side.
  ///
  /// Retries with backoff (bounded by [defaultUnlockRetryDelays], ~10s in
  /// total) and returns the last fetched lesson — which may still be masked
  /// when the webhook has not landed yet; callers must check
  /// [Lesson.isBodyMasked] and offer a manual retry.
  Future<Lesson?> getUnlockedLessonById(String id) async {
    var lesson = await getLessonById(id);
    for (final delay in _unlockRetryDelays) {
      if (lesson == null || !lesson.isBodyMasked) return lesson;
      await Future<void>.delayed(delay);
      lesson = await getLessonById(id);
    }
    return lesson;
  }

  /// Refetches all lessons until no paid body is masked anymore.
  ///
  /// Same bounded backoff as [getUnlockedLessonById]; returns the last
  /// fetched list even when some bodies are still masked.
  Future<List<Lesson>> getAllLessonsUnlocked() async {
    var lessons = await getAllLessons();
    for (final delay in _unlockRetryDelays) {
      if (!lessons.any((lesson) => lesson.isBodyMasked)) return lessons;
      await Future<void>.delayed(delay);
      lessons = await getAllLessons();
    }
    return lessons;
  }
}
