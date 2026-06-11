import 'dart:convert';

import 'package:belaraby/data/models/practice_word_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Device-local storage for custom practice words — words the user taps in
/// a story and adds to the flashcard deck. These deliberately stay OFF the
/// backend (they are personal scratch vocabulary, not lesson content); the
/// curated keyword deck remains server-side in `user_practice_words`.
class LocalPracticeStore {
  LocalPracticeStore({SharedPreferences? preferences})
    : _preferences = preferences;

  static const String _key = 'custom_practice_words';

  /// Prefix marking deck entries that live in this store rather than the
  /// backend (the practice id is the prefix followed by the word).
  static const String idPrefix = 'local:';

  SharedPreferences? _preferences;

  Future<SharedPreferences> _prefs() async =>
      _preferences ??= await SharedPreferences.getInstance();

  /// Returns the stored custom words as [PracticeWord]s.
  Future<List<PracticeWord>> fetchWords() async {
    final prefs = await _prefs();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];
    final entries = (jsonDecode(raw) as List<dynamic>)
        .cast<Map<String, dynamic>>();
    return [
      for (final entry in entries)
        PracticeWord(
          id: '$idPrefix${entry['word']}',
          keywordId: '',
          word: entry['word'] as String? ?? '',
          meaning: entry['meaning'] as String? ?? '',
          difficulty: PracticeDifficulty.fromDb(
            entry['difficulty'] as String?,
          ),
        ),
    ];
  }

  /// Adds [word] (no-op when it is already stored).
  Future<void> addWord(String word, String meaning) async {
    final entries = await _readEntries();
    if (entries.any((entry) => entry['word'] == word)) return;
    entries.add({
      'word': word,
      'meaning': meaning,
      'difficulty': PracticeDifficulty.newWord.dbValue,
    });
    await _writeEntries(entries);
  }

  /// Removes [word].
  Future<void> removeWord(String word) async {
    final entries = await _readEntries();
    entries.removeWhere((entry) => entry['word'] == word);
    await _writeEntries(entries);
  }

  /// Records the self-assessed difficulty of [word].
  Future<void> setDifficulty(
    String word,
    PracticeDifficulty difficulty,
  ) async {
    final entries = await _readEntries();
    for (final entry in entries) {
      if (entry['word'] == word) entry['difficulty'] = difficulty.dbValue;
    }
    await _writeEntries(entries);
  }

  Future<List<Map<String, dynamic>>> _readEntries() async {
    final prefs = await _prefs();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    return (jsonDecode(raw) as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  Future<void> _writeEntries(List<Map<String, dynamic>> entries) async {
    final prefs = await _prefs();
    await prefs.setString(_key, jsonEncode(entries));
  }
}
