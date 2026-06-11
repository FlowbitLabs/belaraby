import 'package:belaraby/app/lesson/cubit/quiz_cubit.dart';
import 'package:belaraby/app/lesson/widgets/quiz_progress_ring.dart';
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
      question: 'q1',
      options: [
        LessonExerciseOption(
          id: 'op1',
          exerciseId: 'ex1',
          optionText: 'a',
          isCorrect: true,
        ),
      ],
    ),
    LessonExercise(
      id: 'ex2',
      lessonId: 'l1',
      question: 'q2',
      options: [
        LessonExerciseOption(
          id: 'op2',
          exerciseId: 'ex2',
          optionText: 'b',
          isCorrect: true,
        ),
      ],
    ),
  ];

  setUp(() {
    repository = MockLessonContentRepository();
  });

  Future<QuizCubit> pumpRing(WidgetTester tester) async {
    final cubit = QuizCubit(lessonId: 'l1', repository: repository);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: const Scaffold(body: Center(child: QuizProgressRing())),
        ),
      ),
    );
    return cubit;
  }

  testWidgets('renders nothing before the exercises load', (tester) async {
    await pumpRing(tester);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('shows answered/total and fills as answers come in', (
    tester,
  ) async {
    when(() => repository.fetchExercises('l1'))
        .thenAnswer((_) async => exercises);
    final cubit = await pumpRing(tester);
    await cubit.loadExercises();
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('0/2'), findsOneWidget);

    cubit.selectOption('ex1', 'op1');
    await tester.pumpAndSettle();
    expect(find.text('1/2'), findsOneWidget);

    // Completed: the count gives way to a checkmark.
    cubit.selectOption('ex2', 'op2');
    await tester.pumpAndSettle();
    expect(find.text('2/2'), findsNothing);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('renders nothing when the lesson has no quiz', (tester) async {
    when(() => repository.fetchExercises('l1')).thenAnswer((_) async => []);
    final cubit = await pumpRing(tester);
    await cubit.loadExercises();
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
