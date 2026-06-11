import 'dart:async';

import 'package:belaraby/data/repositories/auth_repository.dart';
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
    bool demoPremiumAllowed = kIsWeb,
  }) : _purchasesService = purchasesService,
       _authRepository = authRepository ?? AuthRepository(),
       _demoPremiumAllowed = demoPremiumAllowed,
       super(const SubscriptionState()) {
    _customerInfoSubscription = _purchasesService.customerInfoStream.listen(
      _onCustomerInfoUpdated,
    );
  }

  final PurchasesService _purchasesService;
  final AuthRepository _authRepository;

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

  /// WEB DEMO ONLY: locally simulates a premium account so the premium UI
  /// states (tier badge, unlocked paywall gate) can be demonstrated without
  /// a store purchase. Purely client-side — nothing is written server-side,
  /// so paid story bodies stay masked by the backend. No-op outside web.
  void toggleDemoPremium() {
    if (!_demoPremiumAllowed) return;
    final enabled = !state.isDemoPremium;
    emit(
      state.copyWith(
        status: SubscriptionStatus.success,
        isDemoPremium: enabled,
        isPremium: enabled,
        errorMessage: '',
        infoMessage: enabled
            ? 'profile_demo_enabled'
            : 'profile_demo_disabled',
      ),
    );
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
      emit(
        state.copyWith(
          status: SubscriptionStatus.success,
          isBillingAvailable: false,
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
      debugPrint('SubscriptionCubit.purchase failed: $error');
      emit(
        state.copyWith(
          status: SubscriptionStatus.error,
          errorMessage: 'paywall_error_purchase',
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
    this.isBillingAvailable = true,
    this.packages = const [],
    this.errorMessage = '',
    this.infoMessage = '',
  });

  final SubscriptionStatus status;
  final bool isPremium;

  /// Whether [isPremium] is only simulated by the web demo toggle.
  final bool isDemoPremium;
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
    isBillingAvailable,
    packages,
    errorMessage,
    infoMessage,
  ];

  SubscriptionState copyWith({
    SubscriptionStatus? status,
    bool? isPremium,
    bool? isDemoPremium,
    bool? isBillingAvailable,
    List<Package>? packages,
    String? errorMessage,
    String? infoMessage,
  }) {
    return SubscriptionState(
      status: status ?? this.status,
      isPremium: isPremium ?? this.isPremium,
      isDemoPremium: isDemoPremium ?? this.isDemoPremium,
      isBillingAvailable: isBillingAvailable ?? this.isBillingAvailable,
      packages: packages ?? this.packages,
      errorMessage: errorMessage ?? this.errorMessage,
      infoMessage: infoMessage ?? this.infoMessage,
    );
  }
}
