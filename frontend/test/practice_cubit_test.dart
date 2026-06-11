import 'package:belaraby/app/practice/cubit/practice_cubit.dart';
import 'package:belaraby/data/models/practice_word_model.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers.dart';

void main() {
  late MockPracticeRepository repository;
  late MockLocalPracticeStore localStore;

  const hardWord = PracticeWord(
    id: 'p1',
    keywordId: 'k1',
    word: 'عَوْلَمَة',
    meaning: 'ترابط دول العالم',
    difficulty: PracticeDifficulty.hard,
  );
  const newWord = PracticeWord(
    id: 'p2',
    keywordId: 'k2',
    word: 'تَلَوُّث',
    meaning: 'إفساد البيئة',
    difficulty: PracticeDifficulty.newWord,
  );
  const doneWord = PracticeWord(
    id: 'p3',
    keywordId: 'k3',
    word: 'سُوق',
    meaning: 'مكان البيع',
    difficulty: PracticeDifficulty.done,
  );

  setUp(() {
    repository = MockPracticeRepository();
    localStore = MockLocalPracticeStore();
    when(localStore.fetchWords).thenAnswer((_) async => const []);
  });

  PracticeCubit buildCubit() =>
      PracticeCubit(repository: repository, localStore: localStore);

  test('PracticeWord.fromJson maps the joined keyword', () {
    final word = PracticeWord.fromJson(const {
      'id': 'p1',
      'difficulty': 'hard',
      'lesson_keywords': {
        'id': 'k1',
        'keyword': 'كلمة',
        'meaning': 'معنى',
      },
    });
    expect(word.word, 'كلمة');
    expect(word.meaning, 'معنى');
    expect(word.difficulty, PracticeDifficulty.hard);

    expect(PracticeDifficulty.fromDb('bogus'), PracticeDifficulty.newWord);
  });

  test('trainingDeck excludes mastered words, hardest first', () {
    const state = PracticeState(words: [newWord, doneWord, hardWord]);
    expect(state.trainingDeck, [hardWord, newWord]);
    expect(state.keywordIds, {'k1', 'k2', 'k3'});
  });

  blocTest<PracticeCubit, PracticeState>(
    'loads the practice deck',
    setUp: () {
      when(repository.fetchPracticeWords)
          .thenAnswer((_) async => [hardWord]);
    },
    build: buildCubit,
    act: (cubit) => cubit.loadPractice(),
    expect: () => [
      const PracticeState(status: PracticeStatus.loading),
      const PracticeState(
        status: PracticeStatus.success,
        words: [hardWord],
      ),
    ],
  );

  blocTest<PracticeCubit, PracticeState>(
    'toggleWord removes optimistically and reverts on failure',
    setUp: () {
      when(() => repository.removeWord('k1')).thenThrow(Exception('x'));
    },
    build: buildCubit,
    seed: () => const PracticeState(
      status: PracticeStatus.success,
      words: [hardWord],
    ),
    act: (cubit) => cubit.toggleWord('k1'),
    expect: () => [
      const PracticeState(status: PracticeStatus.success),
      const PracticeState(
        status: PracticeStatus.success,
        words: [hardWord],
        errorMessage: 'practice_update_error',
      ),
      const PracticeState(status: PracticeStatus.success, words: [hardWord]),
    ],
  );

  blocTest<PracticeCubit, PracticeState>(
    'toggleCustomWord stores a device-local word and removes it again',
    setUp: () {
      when(() => localStore.addWord('قمر', 'moon')).thenAnswer((_) async {});
      when(() => localStore.removeWord('قمر')).thenAnswer((_) async {});
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.toggleCustomWord('قمر', 'moon');
      await cubit.toggleCustomWord('قمر', 'moon');
    },
    expect: () => [
      isA<PracticeState>()
          .having((state) => state.customWords, 'customWords', {'قمر'})
          .having(
            (state) => state.words.single.isCustom,
            'isCustom',
            isTrue,
          ),
      isA<PracticeState>().having(
        (state) => state.words,
        'words',
        isEmpty,
      ),
    ],
  );

  blocTest<PracticeCubit, PracticeState>(
    'setDifficulty updates the word optimistically',
    setUp: () {
      when(
        () => repository.setDifficulty('p2', PracticeDifficulty.easy),
      ).thenAnswer((_) async {});
    },
    build: buildCubit,
    seed: () => const PracticeState(
      status: PracticeStatus.success,
      words: [newWord],
    ),
    act: (cubit) => cubit.setDifficulty('p2', PracticeDifficulty.easy),
    expect: () => [
      isA<PracticeState>().having(
        (state) => state.words.single.difficulty,
        'difficulty',
        PracticeDifficulty.easy,
      ),
    ],
  );
}
