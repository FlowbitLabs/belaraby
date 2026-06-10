import 'package:belaraby/app/paywall/view/paywall_page.dart';
import 'package:belaraby/app/subscription/cubit/subscription_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'helpers.dart';

class MockSubscriptionCubit extends MockCubit<SubscriptionState>
    implements SubscriptionCubit {}

void main() {
  late MockSubscriptionCubit cubit;

  setUp(() {
    cubit = MockSubscriptionCubit();
    // PaywallView triggers a load() in initState.
    when(() => cubit.load()).thenAnswer((_) async {});
  });

  // Without an initialized EasyLocalization, tr() falls back to returning
  // the translation key itself — assertions below match on keys.
  Widget buildSubject() {
    return BlocProvider<SubscriptionCubit>.value(
      value: cubit,
      child: const MaterialApp(home: PaywallPage()),
    );
  }

  void stubState(SubscriptionState state) {
    whenListen(
      cubit,
      const Stream<SubscriptionState>.empty(),
      initialState: state,
    );
  }

  testWidgets('shows a message when billing is unavailable', (tester) async {
    stubState(
      const SubscriptionState(
        status: SubscriptionStatus.success,
        isBillingAvailable: false,
      ),
    );

    await tester.pumpWidget(buildSubject());

    expect(find.text('paywall_billing_unavailable'), findsOneWidget);
    expect(find.text('paywall_subscribe'), findsNothing);
  });

  testWidgets('shows a spinner while loading', (tester) async {
    stubState(const SubscriptionState(status: SubscriptionStatus.loading));

    await tester.pumpWidget(buildSubject());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows a message when no packages are available', (
    tester,
  ) async {
    stubState(const SubscriptionState(status: SubscriptionStatus.success));

    await tester.pumpWidget(buildSubject());

    expect(find.text('paywall_no_packages'), findsOneWidget);
  });

  testWidgets('renders a card with store price per package', (tester) async {
    final monthly = buildPackage();
    final yearly = buildPackage(
      type: PackageType.annual,
      price: r'US$39.99',
    );
    stubState(
      SubscriptionState(
        status: SubscriptionStatus.success,
        packages: [monthly, yearly],
      ),
    );

    await tester.pumpWidget(buildSubject());

    expect(find.text('paywall_monthly'), findsOneWidget);
    expect(find.text('paywall_yearly'), findsOneWidget);
    expect(find.text(r'US$4.99'), findsOneWidget);
    expect(find.text(r'US$39.99'), findsOneWidget);
    expect(find.text('paywall_subscribe'), findsNWidgets(2));
    // Apple 3.1.2: per-duration price lines plus the renewal terms.
    expect(find.text('paywall_renewal_monthly'), findsOneWidget);
    expect(find.text('paywall_renewal_yearly'), findsOneWidget);
    expect(find.text('paywall_renewal_terms'), findsOneWidget);
  });

  testWidgets('tapping subscribe purchases that package', (tester) async {
    final monthly = buildPackage();
    stubState(
      SubscriptionState(
        status: SubscriptionStatus.success,
        packages: [monthly],
      ),
    );
    when(() => cubit.purchase(monthly)).thenAnswer((_) async {});

    await tester.pumpWidget(buildSubject());
    await tester.tap(find.text('paywall_subscribe'));

    verify(() => cubit.purchase(monthly)).called(1);
  });

  testWidgets('shows tappable legal links (Apple 3.1.2)', (tester) async {
    stubState(const SubscriptionState(status: SubscriptionStatus.success));

    await tester.pumpWidget(buildSubject());

    final privacy = find.text('legal_privacy_policy');
    final terms = find.text('legal_terms_of_use');
    expect(privacy, findsOneWidget);
    expect(terms, findsOneWidget);
    expect(
      find.ancestor(of: privacy, matching: find.byType(TextButton)),
      findsOneWidget,
    );
    expect(
      find.ancestor(of: terms, matching: find.byType(TextButton)),
      findsOneWidget,
    );
  });

  testWidgets('restore button asks the cubit to restore', (tester) async {
    stubState(const SubscriptionState(status: SubscriptionStatus.success));
    when(() => cubit.restore()).thenAnswer((_) async {});

    await tester.pumpWidget(buildSubject());
    await tester.tap(find.text('paywall_restore'));

    verify(() => cubit.restore()).called(1);
  });

  testWidgets('pops with true after the purchase succeeds', (tester) async {
    whenListen(
      cubit,
      Stream.fromIterable(const [
        SubscriptionState(status: SubscriptionStatus.loading),
        SubscriptionState(
          status: SubscriptionStatus.success,
          isPremium: true,
        ),
      ]),
      initialState: const SubscriptionState(
        status: SubscriptionStatus.success,
      ),
    );

    bool? result;
    await tester.pumpWidget(
      BlocProvider<SubscriptionCubit>.value(
        value: cubit,
        child: MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute<bool>(
                    builder: (_) => const PaywallPage(),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(PaywallPage), findsNothing);
    expect(result, isTrue);
  });
}
