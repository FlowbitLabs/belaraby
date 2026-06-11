import 'package:belaraby/app/lesson/cubit/grammar_cubit.dart';
import 'package:belaraby/app/lesson/cubit/keywords_cubit.dart';
import 'package:belaraby/app/lesson/cubit/quiz_cubit.dart';
import 'package:belaraby/app/lesson/tab_views/grammar_tab_view.dart';
import 'package:belaraby/data/models/lesson_exercise_model.dart';
import 'package:belaraby/data/models/lesson_grammar_model.dart';
import 'package:belaraby/data/models/lesson_keyword_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LessonExercise.fromJson', () {
    test('parses the joined options', () {
      final exercise = LessonExercise.fromJson(const {
        'id': 'ex1',
        'lesson_id': 'l1',
        'question': 'ما عاصمة مصر؟',
        'lesson_exercise_options': [
          {
            'id': 'op1',
            'exercise_id': 'ex1',
            'option_text': 'القاهرة',
            'is_correct': true,
          },
          {
            'id': 'op2',
            'exercise_id': 'ex1',
            'option_text': 'الرياض',
            'is_correct': false,
          },
        ],
      });
      expect(exercise.id, 'ex1');
      expect(exercise.lessonId, 'l1');
      expect(exercise.options.length, 2);
      expect(exercise.options.first.isCorrect, isTrue);
      expect(exercise.options.last.optionText, 'الرياض');
    });

    test('tolerates missing options and null is_correct', () {
      final exercise = LessonExercise.fromJson(const {
        'id': 'ex1',
        'lesson_id': 'l1',
        'question': 'سؤال',
      });
      expect(exercise.options, isEmpty);

      final option = LessonExerciseOption.fromJson(const {
        'id': 'op1',
        'exercise_id': 'ex1',
        'option_text': 'خيار',
        'is_correct': null,
      });
      expect(option.isCorrect, isFalse);
    });
  });

  group('LessonKeyword/LessonGrammarItem fromJson', () {
    test('parse their columns', () {
      final keyword = LessonKeyword.fromJson(const {
        'id': 'k1',
        'lesson_id': 'l1',
        'keyword': 'مدرسة',
      });
      expect(keyword.keyword, 'مدرسة');

      final grammar = LessonGrammarItem.fromJson(const {
        'id': 'g1',
        'lesson_id': 'l1',
        'title': 'الضمائر',
        'explanation': 'شرح القاعدة',
        'example': 'أنا أدرس',
      });
      expect(grammar.title, 'الضمائر');
      expect(grammar.explanation, 'شرح القاعدة');
      expect(grammar.example, 'أنا أدرس');

      // Rows authored before the title/example columns existed.
      final legacy = LessonGrammarItem.fromJson(const {
        'id': 'g2',
        'lesson_id': 'l1',
        'explanation': 'شرح',
      });
      expect(legacy.title, isEmpty);
      expect(legacy.example, isNull);
    });
  });


  group('GrammarCard', () {
    Future<void> pump(WidgetTester tester, LessonGrammarItem item) {
      return tester.pumpWidget(
        MaterialApp(home: Scaffold(body: GrammarCard(item: item))),
      );
    }

    testWidgets('renders title, explanation and example', (tester) async {
      const item = LessonGrammarItem(
        id: 'g1',
        lessonId: 'l1',
        title: 'الضمائر',
        explanation: 'شرح القاعدة',
        example: 'أنا أدرس',
      );
      await pump(tester, item);
      expect(find.text('الضمائر'), findsOneWidget);
      expect(find.text('شرح القاعدة'), findsOneWidget);
      expect(find.text('أنا أدرس'), findsOneWidget);
    });

    testWidgets('hides the heading and example box for legacy rows', (
      tester,
    ) async {
      const item = LessonGrammarItem(
        id: 'g2',
        lessonId: 'l1',
        title: '',
        explanation: 'شرح',
      );
      await pump(tester, item);
      expect(find.text('شرح'), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb_outline), findsNothing);
      expect(find.byType(Container), findsNothing);
    });
  });

  group('QuizState', () {
    const exercises = [
      LessonExercise(
        id: 'ex1',
        lessonId: 'l1',
        question: 'q1',
        options: [
          LessonExerciseOption(
            id: 'op1',
            exerciseId: 'ex1',
            optionText: 'a',
            isCorrect: true,
          ),
          LessonExerciseOption(
            id: 'op2',
            exerciseId: 'ex1',
            optionText: 'b',
            isCorrect: false,
          ),
        ],
      ),
      LessonExercise(
        id: 'ex2',
        lessonId: 'l1',
        question: 'q2',
        options: [
          LessonExerciseOption(
            id: 'op3',
            exerciseId: 'ex2',
            optionText: 'c',
            isCorrect: true,
          ),
        ],
      ),
    ];

    test('isCompleted requires an answer for every exercise', () {
      const state = QuizState(exercises: exercises);
      expect(state.isCompleted, isFalse);

      final partial = state.copyWith(selectedOptions: {'ex1': 'op1'});
      expect(partial.isCompleted, isFalse);

      final complete = state.copyWith(
        selectedOptions: {'ex1': 'op1', 'ex2': 'op3'},
      );
      expect(complete.isCompleted, isTrue);
    });

    test('correctCount counts correctly answered exercises', () {
      const state = QuizState(
        exercises: exercises,
        selectedOptions: {'ex1': 'op2', 'ex2': 'op3'},
      );
      expect(state.correctCount, 1);
    });

    test('selectedOptionId returns the recorded answer', () {
      const state = QuizState(selectedOptions: {'ex1': 'op1'});
      expect(state.selectedOptionId('ex1'), 'op1');
      expect(state.selectedOptionId('ex2'), isNull);
    });

    test('answeredCount and progress track the loaded exercises', () {
      const state = QuizState(exercises: exercises);
      expect(state.answeredCount, 0);
      expect(state.progress, 0);

      final half = state.copyWith(selectedOptions: {'ex1': 'op1'});
      expect(half.answeredCount, 1);
      expect(half.progress, 0.5);

      // Stale answers for exercises that are no longer loaded don't count.
      final stale = state.copyWith(selectedOptions: {'gone': 'op9'});
      expect(stale.answeredCount, 0);

      expect(const QuizState().progress, 0);
    });
  });

  group('KeywordsState / GrammarState', () {
    test('copyWith overrides only the given fields', () {
      const keywords = KeywordsState();
      final updatedKeywords = keywords.copyWith(
        status: KeywordsStatus.success,
      );
      expect(updatedKeywords.status, KeywordsStatus.success);
      expect(updatedKeywords.keywords, keywords.keywords);

      const grammar = GrammarState();
      final updatedGrammar = grammar.copyWith(status: GrammarStatus.error);
      expect(updatedGrammar.status, GrammarStatus.error);
      expect(updatedGrammar.items, grammar.items);
    });
  });
}
