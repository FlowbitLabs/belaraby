import 'package:belaraby/data/models/lesson_model.dart';
import 'package:belaraby/data/repositories/auth_repository.dart';
import 'package:belaraby/data/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository for the user's personal library.
///
/// Owns all Supabase access to the `user_favorites` and
/// `user_learned_lessons` tables. Rows are scoped to the authenticated
/// user; when the bootstrap anonymous sign-in failed (e.g. offline first
/// boot) every operation retries it first, so the session self-heals once
/// connectivity returns instead of failing until an app restart.
class LibraryRepository {
  LibraryRepository({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();

  static const String _favoritesTable = 'user_favorites';
  static const String _learnedTable = 'user_learned_lessons';

  final AuthRepository _authRepository;

  /// Resolves the authenticated user id, signing in anonymously first when
  /// no session exists yet (cheap no-op when one does).
  Future<String> _requireUserId() async {
    final userId = await _authRepository.ensureSignedIn();
    if (userId == null) {
      throw const AuthException('No authenticated user.');
    }
    return userId;
  }

  /// Returns the user's favorite lessons (joined to `lessons`).
  Future<List<Lesson>> fetchFavorites() => _fetchLessons(_favoritesTable);

  /// Returns the lessons the user marked as learned (joined to `lessons`).
  Future<List<Lesson>> fetchLearned() => _fetchLessons(_learnedTable);

  /// Whether the lesson with [lessonId] is in the user's favorites.
  Future<bool> isFavorite(String lessonId) =>
      _exists(_favoritesTable, lessonId);

  /// Whether the lesson with [lessonId] is marked as learned.
  Future<bool> isLearned(String lessonId) => _exists(_learnedTable, lessonId);

  /// Adds the lesson with [lessonId] to the user's favorites.
  Future<void> addFavorite(String lessonId) => _add(_favoritesTable, lessonId);

  /// Removes the lesson with [lessonId] from the user's favorites.
  Future<void> removeFavorite(String lessonId) =>
      _remove(_favoritesTable, lessonId);

  /// Marks the lesson with [lessonId] as learned.
  Future<void> markLearned(String lessonId) => _add(_learnedTable, lessonId);

  /// Removes the learned mark from the lesson with [lessonId].
  Future<void> unmarkLearned(String lessonId) =>
      _remove(_learnedTable, lessonId);

  Future<List<Lesson>> _fetchLessons(String table) async {
    final userId = await _requireUserId();
    return supabase
        .from(table)
        .select('lesson_id, lessons(*)')
        .eq('user_id', userId)
        .withConverter(
          (data) => data
              .map(
                (row) =>
                    Lesson.fromJson(row['lessons'] as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  Future<bool> _exists(String table, String lessonId) async {
    final userId = await _requireUserId();
    return supabase
        .from(table)
        .select('lesson_id')
        .eq('user_id', userId)
        .eq('lesson_id', lessonId)
        .maybeSingle()
        .withConverter((data) => data != null);
  }

  Future<void> _add(String table, String lessonId) async {
    final userId = await _requireUserId();
    // ignoreDuplicates (ON CONFLICT DO NOTHING) is required: the default
    // merge behavior needs the UPDATE table privilege, which authenticated
    // users intentionally do not have on these tables.
    await supabase.from(table).upsert(
      {'user_id': userId, 'lesson_id': lessonId},
      ignoreDuplicates: true,
    );
  }

  Future<void> _remove(String table, String lessonId) async {
    final userId = await _requireUserId();
    await supabase
        .from(table)
        .delete()
        .eq('user_id', userId)
        .eq('lesson_id', lessonId);
  }
}
