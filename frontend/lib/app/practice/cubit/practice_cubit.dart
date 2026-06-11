import 'package:belaraby/data/models/practice_word_model.dart';
import 'package:belaraby/data/repositories/practice_repository.dart';
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
  PracticeCubit({PracticeRepository? repository})
    : _repository = repository ?? PracticeRepository(),
      super(const PracticeState());

  final PracticeRepository _repository;

  /// Loads the practice deck.
  Future<void> loadPractice() async {
    emit(state.copyWith(status: PracticeStatus.loading));
    try {
      final words = await _repository.fetchPracticeWords();
      emit(state.copyWith(status: PracticeStatus.success, words: words));
    } on Exception catch (error) {
      debugPrint('PracticeCubit.loadPractice failed: $error');
      emit(state.copyWith(status: PracticeStatus.error));
    }
  }

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
      await _repository.setDifficulty(practiceId, difficulty);
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
  Set<String> get keywordIds =>
      words.map((word) => word.keywordId).toSet();

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
