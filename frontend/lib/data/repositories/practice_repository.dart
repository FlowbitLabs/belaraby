import 'package:belaraby/data/models/practice_word_model.dart';
import 'package:belaraby/data/repositories/auth_repository.dart';
import 'package:belaraby/data/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository for the user's flashcard practice deck
/// (`user_practice_words`, joined to `lesson_keywords`).
///
/// Rows are scoped to the authenticated user; operations retry the
/// anonymous sign-in first so the session self-heals (same pattern as
/// LibraryRepository).
class PracticeRepository {
  PracticeRepository({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();

  static const String _table = 'user_practice_words';

  final AuthRepository _authRepository;

  Future<String> _requireUserId() async {
    final userId = await _authRepository.ensureSignedIn();
    if (userId == null) {
      throw const AuthException('No authenticated user.');
    }
    return userId;
  }

  /// Returns the user's practice deck, keywords included.
  Future<List<PracticeWord>> fetchPracticeWords() async {
    final userId = await _requireUserId();
    return supabase
        .from(_table)
        .select('id, difficulty, lesson_keywords(id, keyword, meaning)')
        .eq('user_id', userId)
        .order('created_at')
        .withConverter((data) => data.map(PracticeWord.fromJson).toList());
  }

  /// Adds the keyword to the deck (no-op when it is already there).
  Future<void> addWord(String keywordId) async {
    final userId = await _requireUserId();
    await supabase.from(_table).upsert({
      'user_id': userId,
      'keyword_id': keywordId,
    }, onConflict: 'user_id,keyword_id', ignoreDuplicates: true);
  }

  /// Removes the keyword from the deck.
  Future<void> removeWord(String keywordId) async {
    final userId = await _requireUserId();
    await supabase
        .from(_table)
        .delete()
        .eq('user_id', userId)
        .eq('keyword_id', keywordId);
  }

  /// Records the self-assessed difficulty for the practice row [id].
  Future<void> setDifficulty(String id, PracticeDifficulty difficulty) async {
    final userId = await _requireUserId();
    await supabase
        .from(_table)
        .update({
          'difficulty': difficulty.dbValue,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('user_id', userId)
        .eq('id', id);
  }
}
