/// Self-assessed difficulty of a practice word, set during flashcard
/// training. `newWord` until the first review; `done` means mastered.
enum PracticeDifficulty {
  newWord('new'),
  easy('easy'),
  medium('medium'),
  hard('hard'),
  done('done');

  const PracticeDifficulty(this.dbValue);

  /// The value stored in `user_practice_words.difficulty`.
  final String dbValue;

  static PracticeDifficulty fromDb(String? value) =>
      PracticeDifficulty.values.firstWhere(
        (difficulty) => difficulty.dbValue == value,
        orElse: () => PracticeDifficulty.newWord,
      );
}

/// A keyword the user added to their practice deck
/// (`user_practice_words` joined to `lesson_keywords`).
class PracticeWord {
  const PracticeWord({
    required this.id,
    required this.keywordId,
    required this.word,
    required this.meaning,
    required this.difficulty,
  });

  /// Maps a `user_practice_words` row (with the joined keyword) to a
  /// [PracticeWord].
  factory PracticeWord.fromJson(Map<String, dynamic> json) {
    final keyword = json['lesson_keywords'] as Map<String, dynamic>? ?? {};
    return PracticeWord(
      id: json['id'] as String,
      keywordId: keyword['id'] as String? ?? '',
      word: keyword['keyword'] as String? ?? '',
      meaning: keyword['meaning'] as String? ?? '',
      difficulty: PracticeDifficulty.fromDb(json['difficulty'] as String?),
    );
  }

  final String id;
  final String keywordId;
  final String word;
  final String meaning;
  final PracticeDifficulty difficulty;

  /// Whether this entry is a device-local custom word (added from a story)
  /// rather than a server-side curated keyword.
  bool get isCustom => id.startsWith('local:');

  PracticeWord copyWith({PracticeDifficulty? difficulty}) => PracticeWord(
    id: id,
    keywordId: keywordId,
    word: word,
    meaning: meaning,
    difficulty: difficulty ?? this.difficulty,
  );
}
