import 'package:belaraby/app/lesson/view/lesson_unlock_page.dart';
import 'package:belaraby/app/paywall/view/paywall_page.dart';
import 'package:belaraby/app/router.dart';
import 'package:belaraby/app/subscription/cubit/subscription_cubit.dart';
import 'package:belaraby/data/data.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers.dart';

class MockSubscriptionCubit extends MockCubit<SubscriptionState>
    implements SubscriptionCubit {}

void main() {
  late MockSubscriptionCubit cubit;

  setUp(() {
    cubit = MockSubscriptionCubit();
    when(() => cubit.load()).thenAnswer((_) async {});
  });

  Widget buildSubject(Lesson lesson) {
    // The provider sits above the MaterialApp so pushed routes (the
    // paywall) can read the same cubit.
    return BlocProvider<SubscriptionCubit>.value(
      value: cubit,
      child: MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => navigateToLessonGated(context, lesson),
            child: const Text('open'),
          ),
        ),
      ),
    );
  }

  testWidgets('paid lesson routes non-premium users to the paywall', (
    tester,
  ) async {
    whenListen(
      cubit,
      const Stream<SubscriptionState>.empty(),
      initialState: const SubscriptionState(
        status: SubscriptionStatus.success,
        isBillingAvailable: false,
      ),
    );

    await tester.pumpWidget(buildSubject(buildLesson()));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(PaywallPage), findsOneWidget);
  });

  testWidgets('closing the paywall without purchasing opens nothing', (
    tester,
  ) async {
    whenListen(
      cubit,
      const Stream<SubscriptionState>.empty(),
      initialState: const SubscriptionState(
        status: SubscriptionStatus.success,
        isBillingAvailable: false,
      ),
    );

    await tester.pumpWidget(buildSubject(buildLesson()));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.byType(PaywallPage), findsNothing);
    expect(find.byType(LessonUnlockPage), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });

  // The premium/free paths push the LessonPage, whose cubits require the
  // global Supabase client; they are covered by the cubit unit tests
  // instead of widget tests.
}
