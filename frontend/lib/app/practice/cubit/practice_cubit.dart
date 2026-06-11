import 'package:belaraby/data/models/practice_word_model.dart';
import 'package:belaraby/data/repositories/practice_repository.dart';
import 'package:belaraby/data/services/local_practice_store.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum PracticeStatus { initial, loading, success, error }

/// Global cubit owning the user's flashcard practice deck.
///
/// Lives above the router (like FavoriteCubit) so the keywords tab can
/// toggle membership and the exercise screen renders the same deck.
/// Mutations are optimistic with revert on failure.
class PracticeCubit extends Cubit<PracticeState> {
  PracticeCubit({
    PracticeRepository? repository,
    LocalPracticeStore? localStore,
  }) : _repository = repository ?? PracticeRepository(),
       _localStore = localStore ?? LocalPracticeStore(),
       super(const PracticeState());

  final PracticeRepository _repository;
  final LocalPracticeStore _localStore;

  /// Loads the practice deck: server-side keyword entries plus the
  /// device-local custom words added from stories.
  Future<void> loadPractice() async {
    emit(state.copyWith(status: PracticeStatus.loading));
    try {
      final words = await _repository.fetchPracticeWords();
      final customWords = await _localStore.fetchWords();
      emit(
        state.copyWith(
          status: PracticeStatus.success,
          words: [...words, ...customWords],
        ),
      );
    } on Exception catch (error) {
      debugPrint('PracticeCubit.loadPractice failed: $error');
      emit(state.copyWith(status: PracticeStatus.error));
    }
  }

  /// Adds or removes a custom story word (kept on this device only).
  Future<void> toggleCustomWord(String word, String meaning) async {
    final previous = state.words;
    final exists = state.customWords.contains(word);
    try {
      if (exists) {
        await _localStore.removeWord(word);
        emit(
          state.copyWith(
            words: previous
                .where((entry) => !(entry.isCustom && entry.word == word))
                .toList(),
          ),
        );
      } else {
        await _localStore.addWord(word, meaning);
        emit(
          state.copyWith(
            status: PracticeStatus.success,
            words: [
              ...previous,
              PracticeWord(
                id: '${LocalPracticeStore.idPrefix}$word',
                keywordId: '',
                word: word,
                meaning: meaning,
                difficulty: PracticeDifficulty.newWord,
              ),
            ],
          ),
        );
      }
    } on Exception catch (error) {
      debugPrint('PracticeCubit.toggleCustomWord failed: $error');
      emit(
        state.copyWith(
          words: previous,
          errorMessage: 'practice_update_error',
        ),
      );
      emit(state.copyWith(errorMessage: ''));
    }
  }

  /// Removes [entry] from the deck, whatever its source.
  Future<void> removeEntry(PracticeWord entry) => entry.isCustom
      ? toggleCustomWord(entry.word, entry.meaning)
      : toggleWord(entry.keywordId);

  /// Adds or removes [keywordId] from the deck, optimistically.
  Future<void> toggleWord(String keywordId) async {
    final previous = state.words;
    final isInDeck = state.keywordIds.contains(keywordId);
    try {
      if (isInDeck) {
        emit(
          state.copyWith(
            words: previous
                .where((word) => word.keywordId != keywordId)
                .toList(),
          ),
        );
        await _repository.removeWord(keywordId);
      } else {
        await _repository.addWord(keywordId);
        // The row id comes from the server — refetch to pick it up.
        final words = await _repository.fetchPracticeWords();
        emit(state.copyWith(status: PracticeStatus.success, words: words));
      }
    } on Exception catch (error) {
      debugPrint('PracticeCubit.toggleWord failed: $error');
      emit(
        state.copyWith(
          words: previous,
          errorMessage: 'practice_update_error',
        ),
      );
      emit(state.copyWith(errorMessage: ''));
    }
  }

  /// Records the difficulty chosen during training, optimistically.
  Future<void> setDifficulty(
    String practiceId,
    PracticeDifficulty difficulty,
  ) async {
    final previous = state.words;
    emit(
      state.copyWith(
        words: [
          for (final word in previous)
            if (word.id == practiceId)
              word.copyWith(difficulty: difficulty)
            else
              word,
        ],
      ),
    );
    try {
      if (practiceId.startsWith(LocalPracticeStore.idPrefix)) {
        await _localStore.setDifficulty(
          practiceId.substring(LocalPracticeStore.idPrefix.length),
          difficulty,
        );
      } else {
        await _repository.setDifficulty(practiceId, difficulty);
      }
    } on Exception catch (error) {
      debugPrint('PracticeCubit.setDifficulty failed: $error');
      emit(
        state.copyWith(
          words: previous,
          errorMessage: 'practice_update_error',
        ),
      );
      emit(state.copyWith(errorMessage: ''));
    }
  }
}

class PracticeState extends Equatable {
  const PracticeState({
    this.status = PracticeStatus.initial,
    this.words = const [],
    this.errorMessage = '',
  });

  final PracticeStatus status;
  final List<PracticeWord> words;

  /// Translation key for the snackbar shown on failures.
  final String errorMessage;

  /// Keyword ids currently in the deck (for the add-to-practice toggles).
  Set<String> get keywordIds => words.map((word) => word.keywordId).toSet();

  /// Custom story words currently in the deck.
  Set<String> get customWords => {
    for (final word in words)
      if (word.isCustom) word.word,
  };

  /// Words of one difficulty bucket.
  List<PracticeWord> byDifficulty(PracticeDifficulty difficulty) =>
      words.where((word) => word.difficulty == difficulty).toList();

  /// The training deck: everything not yet mastered, hardest first.
  List<PracticeWord> get trainingDeck {
    const order = [
      PracticeDifficulty.hard,
      PracticeDifficulty.medium,
      PracticeDifficulty.newWord,
      PracticeDifficulty.easy,
    ];
    return [
      for (final difficulty in order) ...byDifficulty(difficulty),
    ];
  }

  @override
  List<Object?> get props => [status, words, errorMessage];

  PracticeState copyWith({
    PracticeStatus? status,
    List<PracticeWord>? words,
    String? errorMessage,
  }) {
    return PracticeState(
      status: status ?? this.status,
      words: words ?? this.words,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
