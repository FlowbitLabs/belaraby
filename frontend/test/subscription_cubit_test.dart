import 'dart:async';

import 'package:belaraby/app/subscription/cubit/subscription_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'helpers.dart';

void main() {
  late MockPurchasesService purchases;
  late MockAuthRepository auth;
  late MockSubscriptionRepository subscriptions;
  late StreamController<CustomerInfo> customerInfoController;

  // The numeric PlatformException codes RevenueCat reports; mapped by
  // PurchasesErrorHelper.getErrorCode (1 = purchaseCancelledError).
  const cancelledCode = '1';
  const storeProblemCode = '2';

  setUpAll(() {
    registerFallbackValue(MockPackage());
  });

  setUp(() {
    purchases = MockPurchasesService();
    auth = MockAuthRepository();
    subscriptions = MockSubscriptionRepository();
    when(subscriptions.hasActiveSubscription).thenAnswer((_) async => false);
    customerInfoController = StreamController<CustomerInfo>();
    when(
      () => purchases.customerInfoStream,
    ).thenAnswer((_) => customerInfoController.stream);
    when(() => purchases.isBillingAvailable).thenReturn(true);
    when(() => auth.ensureSignedIn()).thenAnswer((_) async => 'user-1');
    when(() => auth.isAnonymous).thenReturn(true);
    when(() => purchases.logIn(any())).thenAnswer((_) async {});
  });

  tearDown(() async {
    await customerInfoController.close();
  });

  SubscriptionCubit buildCubit() => SubscriptionCubit(
    purchasesService: purchases,
    authRepository: auth,
    subscriptionRepository: subscriptions,
  );

  group('demo premium', () {
    SubscriptionCubit buildDemoCubit({bool allowed = true}) =>
        SubscriptionCubit(
          purchasesService: purchases,
          authRepository: auth,
          subscriptionRepository: subscriptions,
          demoPremiumAllowed: allowed,
        );

    blocTest<SubscriptionCubit, SubscriptionState>(
      'subscribes and unsubscribes through the edge function',
      setUp: () {
        when(
          () => subscriptions.setDemoSubscription(subscribe: true),
        ).thenAnswer((_) async => true);
        when(
          () => subscriptions.setDemoSubscription(subscribe: false),
        ).thenAnswer((_) async => false);
      },
      build: buildDemoCubit,
      act: (cubit) async {
        await cubit.toggleDemoPremium();
        await cubit.toggleDemoPremium();
      },
      expect: () => [
        const SubscriptionState(status: SubscriptionStatus.loading),
        const SubscriptionState(
          status: SubscriptionStatus.success,
          isPremium: true,
          isDemoPremium: true,
          infoMessage: 'profile_demo_enabled',
        ),
        const SubscriptionState(
          status: SubscriptionStatus.loading,
          isPremium: true,
          isDemoPremium: true,
        ),
        const SubscriptionState(
          status: SubscriptionStatus.success,
          infoMessage: 'profile_demo_disabled',
        ),
      ],
    );

    blocTest<SubscriptionCubit, SubscriptionState>(
      'emits error when the account is not allowlisted',
      setUp: () {
        when(
          () => subscriptions.setDemoSubscription(subscribe: true),
        ).thenThrow(Exception('403'));
      },
      build: buildDemoCubit,
      act: (cubit) => cubit.toggleDemoPremium(),
      expect: () => [
        const SubscriptionState(status: SubscriptionStatus.loading),
        const SubscriptionState(
          status: SubscriptionStatus.error,
          errorMessage: 'profile_demo_error',
        ),
      ],
    );

    blocTest<SubscriptionCubit, SubscriptionState>(
      'is a no-op outside web',
      build: () => buildDemoCubit(allowed: false),
      act: (cubit) => cubit.toggleDemoPremium(),
      expect: () => <SubscriptionState>[],
    );
  });

  group('load', () {
    final package = buildPackage();

    blocTest<SubscriptionCubit, SubscriptionState>(
      'emits success with premium status and packages',
      setUp: () {
        when(() => purchases.isPremium()).thenAnswer((_) async => true);
        when(
          () => purchases.getAvailablePackages(),
        ).thenAnswer((_) async => [package]);
      },
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        const SubscriptionState(status: SubscriptionStatus.loading),
        SubscriptionState(
          status: SubscriptionStatus.success,
          isPremium: true,
          packages: [package],
        ),
      ],
    );

    blocTest<SubscriptionCubit, SubscriptionState>(
      'emits success with isBillingAvailable false when billing is disabled '
      'without calling the store',
      setUp: () {
        when(() => purchases.isBillingAvailable).thenReturn(false);
        when(subscriptions.hasActiveSubscription).thenAnswer((_) async => true);
      },
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        const SubscriptionState(
          status: SubscriptionStatus.success,
          isBillingAvailable: false,
          // The server-side subscription row is the source of truth here.
          isPremium: true,
        ),
      ],
      verify: (_) {
        verifyNever(() => purchases.getAvailablePackages());
      },
    );

    blocTest<SubscriptionCubit, SubscriptionState>(
      'emits error when the store call fails',
      setUp: () {
        when(() => purchases.isPremium()).thenAnswer((_) async => false);
        when(
          () => purchases.getAvailablePackages(),
        ).thenThrow(Exception('offline'));
      },
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        const SubscriptionState(status: SubscriptionStatus.loading),
        const SubscriptionState(
          status: SubscriptionStatus.error,
          errorMessage: 'paywall_error_load',
        ),
      ],
    );
  });

  group('purchase', () {
    final package = buildPackage();

    blocTest<SubscriptionCubit, SubscriptionState>(
      'identifies the user and emits premium on success',
      setUp: () {
        when(
          () => purchases.purchasePackage(package),
        ).thenAnswer((_) async => buildCustomerInfo(premium: true));
      },
      build: buildCubit,
      act: (cubit) => cubit.purchase(package),
      expect: () => [
        const SubscriptionState(status: SubscriptionStatus.loading),
        const SubscriptionState(
          status: SubscriptionStatus.success,
          isPremium: true,
        ),
      ],
      verify: (_) {
        // Purchases must be attributed to the Supabase user id so the
        // RevenueCat webhook can map them to auth.users.
        verify(() => purchases.logIn('user-1')).called(1);
      },
    );

    blocTest<SubscriptionCubit, SubscriptionState>(
      'emits success without an error when the user cancels',
      setUp: () {
        when(() => purchases.purchasePackage(package)).thenThrow(
          PlatformException(code: cancelledCode),
        );
      },
      build: buildCubit,
      act: (cubit) => cubit.purchase(package),
      expect: () => [
        const SubscriptionState(status: SubscriptionStatus.loading),
        const SubscriptionState(status: SubscriptionStatus.success),
      ],
    );

    blocTest<SubscriptionCubit, SubscriptionState>(
      'emits error when the store reports a failure',
      setUp: () {
        when(() => purchases.purchasePackage(package)).thenThrow(
          PlatformException(code: storeProblemCode),
        );
      },
      build: buildCubit,
      act: (cubit) => cubit.purchase(package),
      expect: () => [
        const SubscriptionState(status: SubscriptionStatus.loading),
        const SubscriptionState(
          status: SubscriptionStatus.error,
          errorMessage: 'paywall_error_purchase',
        ),
      ],
    );

    blocTest<SubscriptionCubit, SubscriptionState>(
      'emits error on unexpected exceptions',
      setUp: () {
        when(
          () => purchases.purchasePackage(package),
        ).thenThrow(Exception('boom'));
      },
      build: buildCubit,
      act: (cubit) => cubit.purchase(package),
      expect: () => [
        const SubscriptionState(status: SubscriptionStatus.loading),
        const SubscriptionState(
          status: SubscriptionStatus.error,
          errorMessage: 'paywall_error_purchase',
        ),
      ],
    );

    blocTest<SubscriptionCubit, SubscriptionState>(
      'blocks the purchase when no Supabase identity can be established',
      setUp: () {
        when(() => auth.ensureSignedIn()).thenAnswer((_) async => null);
      },
      build: buildCubit,
      act: (cubit) => cubit.purchase(package),
      expect: () => [
        const SubscriptionState(status: SubscriptionStatus.loading),
        const SubscriptionState(
          status: SubscriptionStatus.error,
          errorMessage: 'paywall_error_signin',
        ),
      ],
      verify: (_) {
        // Without an identity the purchase would land on an anonymous
        // RevenueCat id the backend cannot map — it must never start.
        verifyNever(() => purchases.purchasePackage(any()));
      },
    );

    blocTest<SubscriptionCubit, SubscriptionState>(
      'emits error when billing is unavailable',
      build: buildCubit,
      seed: () => const SubscriptionState(isBillingAvailable: false),
      act: (cubit) => cubit.purchase(package),
      expect: () => [
        const SubscriptionState(
          status: SubscriptionStatus.error,
          isBillingAvailable: false,
          errorMessage: 'paywall_billing_unavailable',
        ),
      ],
      verify: (_) {
        verifyNever(() => purchases.purchasePackage(any()));
      },
    );
  });

  group('restore', () {
    blocTest<SubscriptionCubit, SubscriptionState>(
      'emits premium when a previous purchase is found',
      setUp: () {
        when(
          () => purchases.restorePurchases(),
        ).thenAnswer((_) async => buildCustomerInfo(premium: true));
      },
      build: buildCubit,
      act: (cubit) => cubit.restore(),
      expect: () => [
        const SubscriptionState(status: SubscriptionStatus.loading),
        const SubscriptionState(
          status: SubscriptionStatus.success,
          isPremium: true,
        ),
      ],
    );

    blocTest<SubscriptionCubit, SubscriptionState>(
      'emits an info message when there is nothing to restore',
      setUp: () {
        when(
          () => purchases.restorePurchases(),
        ).thenAnswer((_) async => buildCustomerInfo(premium: false));
      },
      build: buildCubit,
      act: (cubit) => cubit.restore(),
      expect: () => [
        const SubscriptionState(status: SubscriptionStatus.loading),
        const SubscriptionState(
          status: SubscriptionStatus.success,
          infoMessage: 'paywall_restore_none',
        ),
      ],
    );

    blocTest<SubscriptionCubit, SubscriptionState>(
      'emits error when the restore fails',
      setUp: () {
        when(() => purchases.restorePurchases()).thenThrow(Exception('boom'));
      },
      build: buildCubit,
      act: (cubit) => cubit.restore(),
      expect: () => [
        const SubscriptionState(status: SubscriptionStatus.loading),
        const SubscriptionState(
          status: SubscriptionStatus.error,
          errorMessage: 'paywall_error_restore',
        ),
      ],
    );

    blocTest<SubscriptionCubit, SubscriptionState>(
      'emits error when no Supabase identity can be established',
      setUp: () {
        when(() => auth.ensureSignedIn()).thenAnswer((_) async => null);
      },
      build: buildCubit,
      act: (cubit) => cubit.restore(),
      expect: () => [
        const SubscriptionState(status: SubscriptionStatus.loading),
        const SubscriptionState(
          status: SubscriptionStatus.error,
          errorMessage: 'paywall_error_signin',
        ),
      ],
      verify: (_) {
        verifyNever(() => purchases.restorePurchases());
      },
    );

    blocTest<SubscriptionCubit, SubscriptionState>(
      'emits error when billing is unavailable',
      build: buildCubit,
      seed: () => const SubscriptionState(isBillingAvailable: false),
      act: (cubit) => cubit.restore(),
      expect: () => [
        const SubscriptionState(
          status: SubscriptionStatus.error,
          isBillingAvailable: false,
          errorMessage: 'paywall_billing_unavailable',
        ),
      ],
    );
  });

  group('customer info stream', () {
    test('isPremium follows entitlement updates from RevenueCat', () async {
      final cubit = buildCubit();
      expect(cubit.state.isPremium, isFalse);

      customerInfoController.add(buildCustomerInfo(premium: true));
      await pumpEventQueue();
      expect(cubit.state.isPremium, isTrue);

      customerInfoController.add(buildCustomerInfo(premium: false));
      await pumpEventQueue();
      expect(cubit.state.isPremium, isFalse);

      await cubit.close();
    });

    test('close cancels the subscription', () async {
      final cubit = buildCubit();
      await cubit.close();

      // Events after close must not throw or change state.
      customerInfoController.add(buildCustomerInfo(premium: true));
      await pumpEventQueue();
      expect(cubit.state.isPremium, isFalse);
    });
  });
}
