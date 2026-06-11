import 'dart:async';

import 'package:belaraby/data/repositories/auth_repository.dart';
import 'package:belaraby/data/repositories/subscription_repository.dart';
import 'package:belaraby/data/services/purchases_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

enum SubscriptionStatus { initial, loading, success, error }

/// Global cubit exposing the user's premium status and store packages.
///
/// Consumes [PurchasesService] only — no direct plugin calls from the UI.
class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit({
    required PurchasesService purchasesService,
    AuthRepository? authRepository,
    SubscriptionRepository? subscriptionRepository,
    bool demoPremiumAllowed = kIsWeb,
  }) : _purchasesService = purchasesService,
       _authRepository = authRepository ?? AuthRepository(),
       _subscriptionRepository =
           subscriptionRepository ?? SubscriptionRepository(),
       _demoPremiumAllowed = demoPremiumAllowed,
       super(const SubscriptionState()) {
    _customerInfoSubscription = _purchasesService.customerInfoStream.listen(
      _onCustomerInfoUpdated,
    );
  }

  final PurchasesService _purchasesService;
  final AuthRepository _authRepository;
  final SubscriptionRepository _subscriptionRepository;

  /// Whether the demo-premium toggle is available (web builds only;
  /// overridable in tests).
  final bool _demoPremiumAllowed;
  late final StreamSubscription<CustomerInfo> _customerInfoSubscription;

  /// Makes sure the purchase is attributed to the Supabase user id.
  ///
  /// The startup anonymous sign-in can have failed (e.g. offline first
  /// boot); without a Supabase identity RevenueCat would record the purchase
  /// under an anonymous id the webhook cannot map to `auth.users`. Retries
  /// the sign-in, identifies RevenueCat, and returns whether it is safe to
  /// continue. Emits an error state when no identity could be established.
  Future<bool> _ensureIdentified() async {
    final userId = await _authRepository.ensureSignedIn();
    if (userId == null) {
      emit(
        state.copyWith(
          status: SubscriptionStatus.error,
          errorMessage: 'paywall_error_signin',
        ),
      );
      return false;
    }
    await _purchasesService.logIn(userId);
    return true;
  }

  /// WEB DEMO ONLY: toggles a REAL server-side subscription through the
  /// `demo-subscription` edge function, so paid stories actually unlock —
  /// and can be cancelled again with the same toggle. The endpoint only
  /// accepts allowlisted demo accounts (DEMO_PREMIUM_EMAILS); everyone
  /// else gets a not-authorized error. No-op outside web.
  Future<void> toggleDemoPremium() async {
    if (!_demoPremiumAllowed) return;
    final subscribe = !state.isDemoPremium;
    emit(
      state.copyWith(
        status: SubscriptionStatus.loading,
        errorMessage: '',
        infoMessage: '',
      ),
    );
    try {
      final subscribed = await _subscriptionRepository.setDemoSubscription(
        subscribe: subscribe,
      );
      emit(
        state.copyWith(
          status: SubscriptionStatus.success,
          isDemoPremium: subscribed,
          isPremium: subscribed,
          infoMessage: subscribed
              ? 'profile_demo_enabled'
              : 'profile_demo_disabled',
        ),
      );
    } on Exception catch (error) {
      debugPrint('SubscriptionCubit.toggleDemoPremium failed: $error');
      emit(
        state.copyWith(
          status: SubscriptionStatus.error,
          errorMessage: 'profile_demo_error',
        ),
      );
    }
  }

  void _onCustomerInfoUpdated(CustomerInfo customerInfo) {
    emit(
      state.copyWith(
        isPremium: PurchasesService.hasPremiumEntitlement(customerInfo),
      ),
    );
  }

  /// Loads the premium status and the available store packages.
  Future<void> load() async {
    if (!_purchasesService.isBillingAvailable) {
      // No store billing (web): the server-side subscription row is the
      // only source of truth — the same gate that unmasks paid stories.
      var isPremium = state.isPremium;
      try {
        isPremium = await _subscriptionRepository.hasActiveSubscription();
      } on Exception catch (error) {
        debugPrint('SubscriptionCubit.load (server check) failed: $error');
      }
      // The demo toggle is only shown to signed-in, allowlisted accounts —
      // never to anonymous guests. Resolved fresh on every load so it
      // tracks sign-in/sign-out.
      var isDemoAuthorized = false;
      if (_demoPremiumAllowed && !_authRepository.isAnonymous) {
        isDemoAuthorized = await _subscriptionRepository.isDemoAuthorized();
      }
      emit(
        state.copyWith(
          status: SubscriptionStatus.success,
          isBillingAvailable: false,
          isPremium: isPremium,
          // On web only demo subscriptions exist, so server premium means
          // the demo toggle is on.
          isDemoPremium: _demoPremiumAllowed && isPremium,
          isDemoAuthorized: isDemoAuthorized,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        status: SubscriptionStatus.loading,
        errorMessage: '',
        infoMessage: '',
      ),
    );
    try {
      final isPremium = await _purchasesService.isPremium();
      final packages = await _purchasesService.getAvailablePackages();
      emit(
        state.copyWith(
          status: SubscriptionStatus.success,
          isPremium: isPremium,
          packages: packages,
        ),
      );
    } on Exception catch (error) {
      debugPrint('SubscriptionCubit.load failed: $error');
      emit(
        state.copyWith(
          status: SubscriptionStatus.error,
          errorMessage: 'paywall_error_load',
        ),
      );
    }
  }

  /// Purchases [package] through the store.
  Future<void> purchase(Package package) async {
    if (!state.isBillingAvailable) {
      emit(
        state.copyWith(
          status: SubscriptionStatus.error,
          errorMessage: 'paywall_billing_unavailable',
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        status: SubscriptionStatus.loading,
        errorMessage: '',
        infoMessage: '',
      ),
    );
    if (!await _ensureIdentified()) return;
    try {
      final customerInfo = await _purchasesService.purchasePackage(package);
      emit(
        state.copyWith(
          status: SubscriptionStatus.success,
          isPremium: PurchasesService.hasPremiumEntitlement(customerInfo),
        ),
      );
    } on PlatformException catch (error) {
      if (PurchasesService.isUserCancellation(error)) {
        emit(state.copyWith(status: SubscriptionStatus.success));
        return;
      }
      // Ask to Buy / deferred transactions: not a failure — the entitlement
      // arrives via the customer-info stream once the purchase is approved.
      if (PurchasesService.isPendingPayment(error)) {
        emit(
          state.copyWith(
            status: SubscriptionStatus.success,
            infoMessage: 'paywall_purchase_pending',
          ),
        );
        return;
      }
      debugPrint('SubscriptionCubit.purchase failed: $error');
      emit(
        state.copyWith(
          status: SubscriptionStatus.error,
          errorMessage: PurchasesService.isNetworkFailure(error)
              ? 'paywall_error_network'
              : 'paywall_error_purchase',
        ),
      );
    } on Exception catch (error) {
      debugPrint('SubscriptionCubit.purchase failed: $error');
      emit(
        state.copyWith(
          status: SubscriptionStatus.error,
          errorMessage: 'paywall_error_purchase',
        ),
      );
    }
  }

  /// Restores previous purchases for the current store account.
  Future<void> restore() async {
    if (!state.isBillingAvailable) {
      emit(
        state.copyWith(
          status: SubscriptionStatus.error,
          errorMessage: 'paywall_billing_unavailable',
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        status: SubscriptionStatus.loading,
        errorMessage: '',
        infoMessage: '',
      ),
    );
    if (!await _ensureIdentified()) return;
    try {
      final customerInfo = await _purchasesService.restorePurchases();
      final isPremium = PurchasesService.hasPremiumEntitlement(customerInfo);
      emit(
        state.copyWith(
          status: SubscriptionStatus.success,
          isPremium: isPremium,
          infoMessage: isPremium ? '' : 'paywall_restore_none',
        ),
      );
    } on Exception catch (error) {
      debugPrint('SubscriptionCubit.restore failed: $error');
      emit(
        state.copyWith(
          status: SubscriptionStatus.error,
          errorMessage: 'paywall_error_restore',
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _customerInfoSubscription.cancel();
    return super.close();
  }
}

class SubscriptionState extends Equatable {
  const SubscriptionState({
    this.status = SubscriptionStatus.initial,
    this.isPremium = false,
    this.isDemoPremium = false,
    this.isDemoAuthorized = false,
    this.isBillingAvailable = true,
    this.packages = const [],
    this.errorMessage = '',
    this.infoMessage = '',
  });

  final SubscriptionStatus status;
  final bool isPremium;

  /// Whether [isPremium] is only simulated by the web demo toggle.
  final bool isDemoPremium;

  /// Whether the signed-in account may use the demo toggle (web only;
  /// allowlisted by the demo-subscription edge function).
  final bool isDemoAuthorized;
  final bool isBillingAvailable;
  final List<Package> packages;

  /// Translation key for the snackbar shown on failures.
  final String errorMessage;

  /// Translation key for informational snackbars (e.g. nothing to restore).
  final String infoMessage;

  @override
  List<Object?> get props => [
    status,
    isPremium,
    isDemoPremium,
    isDemoAuthorized,
    isBillingAvailable,
    packages,
    errorMessage,
    infoMessage,
  ];

  SubscriptionState copyWith({
    SubscriptionStatus? status,
    bool? isPremium,
    bool? isDemoPremium,
    bool? isDemoAuthorized,
    bool? isBillingAvailable,
    List<Package>? packages,
    String? errorMessage,
    String? infoMessage,
  }) {
    return SubscriptionState(
      status: status ?? this.status,
      isPremium: isPremium ?? this.isPremium,
      isDemoPremium: isDemoPremium ?? this.isDemoPremium,
      isDemoAuthorized: isDemoAuthorized ?? this.isDemoAuthorized,
      isBillingAvailable: isBillingAvailable ?? this.isBillingAvailable,
      packages: packages ?? this.packages,
      errorMessage: errorMessage ?? this.errorMessage,
      infoMessage: infoMessage ?? this.infoMessage,
    );
  }
}
