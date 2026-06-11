import 'package:belaraby/app/lesson/cubit/grammar_cubit.dart';
import 'package:belaraby/app/lesson/cubit/keywords_cubit.dart';
import 'package:belaraby/app/lesson/cubit/quiz_cubit.dart';
import 'package:belaraby/data/data.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers.dart';

void main() {
  late MockLessonContentRepository repository;

  setUp(() {
    repository = MockLessonContentRepository();
  });

  group('QuizCubit', () {
    const exercise = LessonExercise(
      id: 'ex-1',
      lessonId: 'a',
      question: 'سؤال',
      options: [
        LessonExerciseOption(
          id: 'opt-1',
          exerciseId: 'ex-1',
          optionText: 'صحيح',
          isCorrect: true,
        ),
        LessonExerciseOption(
          id: 'opt-2',
          exerciseId: 'ex-1',
          optionText: 'خطأ',
          isCorrect: false,
        ),
      ],
    );

    QuizCubit buildCubit() => QuizCubit(lessonId: 'a', repository: repository);

    blocTest<QuizCubit, QuizState>(
      'loads the exercises and clears previous answers',
      setUp: () {
        when(
          () => repository.fetchExercises('a'),
        ).thenAnswer((_) async => [exercise]);
      },
      build: buildCubit,
      seed: () => const QuizState(selectedOptions: {'ex-1': 'opt-2'}),
      act: (cubit) => cubit.loadExercises(),
      expect: () => [
        const QuizState(
          status: QuizStatus.loading,
          selectedOptions: {'ex-1': 'opt-2'},
        ),
        const QuizState(status: QuizStatus.success, exercises: [exercise]),
      ],
    );

    blocTest<QuizCubit, QuizState>(
      'emits error on failure',
      setUp: () {
        when(() => repository.fetchExercises('a')).thenThrow(Exception('x'));
      },
      build: buildCubit,
      act: (cubit) => cubit.loadExercises(),
      expect: () => [
        const QuizState(status: QuizStatus.loading),
        const QuizState(status: QuizStatus.error),
      ],
    );

    blocTest<QuizCubit, QuizState>(
      'records only the first answer per exercise',
      build: buildCubit,
      act: (cubit) => cubit
        ..selectOption('ex-1', 'opt-2')
        // Further taps are ignored so the feedback stays stable.
        ..selectOption('ex-1', 'opt-1'),
      expect: () => [
        const QuizState(selectedOptions: {'ex-1': 'opt-2'}),
      ],
    );

    blocTest<QuizCubit, QuizState>(
      'resetAnswers clears all answers',
      build: buildCubit,
      seed: () => const QuizState(selectedOptions: {'ex-1': 'opt-1'}),
      act: (cubit) => cubit.resetAnswers(),
      expect: () => [const QuizState()],
    );
  });

  group('KeywordsCubit', () {
    const keyword = LessonKeyword(id: 'kw-1', lessonId: 'a', keyword: 'كلمة');

    KeywordsCubit buildCubit() =>
        KeywordsCubit(lessonId: 'a', repository: repository);

    blocTest<KeywordsCubit, KeywordsState>(
      'loads the keywords',
      setUp: () {
        when(
          () => repository.fetchKeywords('a'),
        ).thenAnswer((_) async => [keyword]);
      },
      build: buildCubit,
      act: (cubit) => cubit.loadKeywords(),
      expect: () => [
        const KeywordsState(status: KeywordsStatus.loading),
        const KeywordsState(
          status: KeywordsStatus.success,
          keywords: [keyword],
        ),
      ],
    );

    blocTest<KeywordsCubit, KeywordsState>(
      'emits error on failure',
      setUp: () {
        when(() => repository.fetchKeywords('a')).thenThrow(Exception('x'));
      },
      build: buildCubit,
      act: (cubit) => cubit.loadKeywords(),
      expect: () => [
        const KeywordsState(status: KeywordsStatus.loading),
        const KeywordsState(status: KeywordsStatus.error),
      ],
    );
  });

  group('GrammarCubit', () {
    const item = LessonGrammarItem(
      id: 'gr-1',
      lessonId: 'a',
      title: 'الضمائر',
      explanation: 'شرح',
      example: 'أنا أدرس',
    );

    GrammarCubit buildCubit() =>
        GrammarCubit(lessonId: 'a', repository: repository);

    blocTest<GrammarCubit, GrammarState>(
      'loads the grammar items',
      setUp: () {
        when(
          () => repository.fetchGrammar('a'),
        ).thenAnswer((_) async => [item]);
      },
      build: buildCubit,
      act: (cubit) => cubit.loadGrammar(),
      expect: () => [
        const GrammarState(status: GrammarStatus.loading),
        const GrammarState(status: GrammarStatus.success, items: [item]),
      ],
    );

    blocTest<GrammarCubit, GrammarState>(
      'emits error on failure',
      setUp: () {
        when(() => repository.fetchGrammar('a')).thenThrow(Exception('x'));
      },
      build: buildCubit,
      act: (cubit) => cubit.loadGrammar(),
      expect: () => [
        const GrammarState(status: GrammarStatus.loading),
        const GrammarState(status: GrammarStatus.error),
      ],
    );
  });
}
