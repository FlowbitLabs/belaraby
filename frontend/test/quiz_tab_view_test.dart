import 'package:belaraby/app/lesson/cubit/quiz_cubit.dart';
import 'package:belaraby/app/lesson/tab_views/quiz_tab_view.dart';
import 'package:belaraby/data/models/lesson_exercise_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers.dart';

void main() {
  late MockLessonContentRepository repository;

  const exercises = [
    LessonExercise(
      id: 'ex1',
      lessonId: 'l1',
      question: 'سؤال ١',
      options: [
        LessonExerciseOption(
          id: 'op1',
          exerciseId: 'ex1',
          optionText: 'صحيح ١',
          isCorrect: true,
        ),
        LessonExerciseOption(
          id: 'op2',
          exerciseId: 'ex1',
          optionText: 'خطأ ١',
          isCorrect: false,
        ),
      ],
    ),
    LessonExercise(
      id: 'ex2',
      lessonId: 'l1',
      question: 'سؤال ٢',
      options: [
        LessonExerciseOption(
          id: 'op3',
          exerciseId: 'ex2',
          optionText: 'صحيح ٢',
          isCorrect: true,
        ),
        LessonExerciseOption(
          id: 'op4',
          exerciseId: 'ex2',
          optionText: 'خطأ ٢',
          isCorrect: false,
        ),
      ],
    ),
  ];

  setUp(() {
    repository = MockLessonContentRepository();
    when(() => repository.fetchExercises('l1'))
        .thenAnswer((_) async => exercises);
  });

  Future<QuizCubit> pumpQuizTab(WidgetTester tester) async {
    final cubit = QuizCubit(lessonId: 'l1', repository: repository);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: const Scaffold(body: QuizTabView()),
        ),
      ),
    );
    await cubit.loadExercises();
    await tester.pumpAndSettle();
    return cubit;
  }

  testWidgets('shows the summary page once every question is answered', (
    tester,
  ) async {
    final cubit = await pumpQuizTab(tester);
    expect(find.text('سؤال ١'), findsOneWidget);
    expect(find.text('quiz_result_good'), findsNothing);

    cubit
      ..selectOption('ex1', 'op2') // wrong
      ..selectOption('ex2', 'op3'); // correct
    await tester.pumpAndSettle();

    // 1/2 correct -> the middle result tier.
    expect(find.text('quiz_result_good'), findsOneWidget);
    expect(find.text('١/٢'), findsOneWidget);
    // Every review row shows the chosen answer; only wrong rows add the
    // correct one.
    expect(find.text('quiz_your_answer'), findsNWidgets(2));
    expect(find.text('quiz_correct_answer'), findsOneWidget);
    // Both questions appear in the review list.
    expect(find.text('سؤال ١'), findsOneWidget);
    expect(find.text('سؤال ٢'), findsOneWidget);
  });

  testWidgets('retake clears the answers and returns to the questions', (
    tester,
  ) async {
    final cubit = await pumpQuizTab(tester);
    cubit
      ..selectOption('ex1', 'op1')
      ..selectOption('ex2', 'op3');
    await tester.pumpAndSettle();
    // 2/2 correct -> the top result tier.
    expect(find.text('quiz_result_excellent'), findsOneWidget);

    await tester.tap(find.text('quiz_retake'));
    await tester.pumpAndSettle();

    expect(find.text('quiz_result_excellent'), findsNothing);
    expect(find.text('سؤال ١'), findsOneWidget);
    expect(cubit.state.selectedOptions, isEmpty);
  });
}
