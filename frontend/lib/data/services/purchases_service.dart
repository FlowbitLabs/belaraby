import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Thrown when a billing operation is attempted while RevenueCat is not
/// configured (e.g. no API key was provided at build time).
class BillingUnavailableException implements Exception {
  const BillingUnavailableException();

  @override
  String toString() => 'Billing is unavailable: RevenueCat is not configured.';
}

/// Wraps the `purchases_flutter` (RevenueCat) plugin.
///
/// API keys are injected at build time via `--dart-define`:
/// `REVENUECAT_APPLE_API_KEY` and `REVENUECAT_GOOGLE_API_KEY`.
///
/// When no key is available for the current platform the service acts as a
/// no-op stub ([isBillingAvailable] is `false`) so the app keeps working in
/// local development without store credentials.
class PurchasesService {
  PurchasesService();

  /// The RevenueCat entitlement identifier that unlocks premium content.
  static const String premiumEntitlementId = 'premium';

  static const String _appleApiKey = String.fromEnvironment(
    'REVENUECAT_APPLE_API_KEY',
  );
  static const String _googleApiKey = String.fromEnvironment(
    'REVENUECAT_GOOGLE_API_KEY',
  );

  final StreamController<CustomerInfo> _customerInfoController =
      StreamController<CustomerInfo>.broadcast();

  bool _isConfigured = false;

  /// Whether RevenueCat was configured with a valid API key.
  bool get isBillingAvailable => _isConfigured;

  /// Emits every [CustomerInfo] update reported by RevenueCat.
  Stream<CustomerInfo> get customerInfoStream => _customerInfoController.stream;

  /// Whether [customerInfo] grants the `premium` entitlement.
  static bool hasPremiumEntitlement(CustomerInfo customerInfo) =>
      customerInfo.entitlements.active.containsKey(premiumEntitlementId);

  /// Whether [error] represents a user-initiated purchase cancellation.
  static bool isUserCancellation(Object error) =>
      error is PlatformException &&
      PurchasesErrorHelper.getErrorCode(error) ==
          PurchasesErrorCode.purchaseCancelledError;

  /// Whether [error] is a purchase awaiting external approval (e.g. iOS
  /// Ask to Buy / parental controls, or a deferred Play transaction). The
  /// entitlement arrives later via [customerInfoStream] once approved.
  static bool isPendingPayment(Object error) =>
      error is PlatformException &&
      PurchasesErrorHelper.getErrorCode(error) ==
          PurchasesErrorCode.paymentPendingError;

  /// Whether [error] is a connectivity failure (retryable by the user).
  static bool isNetworkFailure(Object error) {
    if (error is! PlatformException) return false;
    final code = PurchasesErrorHelper.getErrorCode(error);
    return code == PurchasesErrorCode.networkError ||
        code == PurchasesErrorCode.offlineConnectionError;
  }

  String get _platformApiKey {
    // purchases_flutter has no web implementation, and on web
    // defaultTargetPlatform reports the browser's OS — so without this guard
    // a web build could wrongly pick a store key and crash on configure.
    if (kIsWeb) return '';
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return _appleApiKey;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _googleApiKey;
    }
    return '';
  }

  /// Configures RevenueCat for the current platform.
  ///
  /// [appUserId] should be the Supabase auth user id so purchases are tied
  /// to the backend identity. Does nothing when the platform API key is
  /// empty; never crashes the app on failure.
  Future<void> init({String? appUserId}) async {
    final apiKey = _platformApiKey;
    if (apiKey.isEmpty) {
      debugPrint(
        'PurchasesService: no RevenueCat API key for this platform; '
        'billing is disabled.',
      );
      return;
    }
    try {
      await Purchases.setLogLevel(
        kDebugMode ? LogLevel.debug : LogLevel.info,
      );
      final configuration = PurchasesConfiguration(apiKey)
        ..appUserID = appUserId;
      await Purchases.configure(configuration);
      Purchases.addCustomerInfoUpdateListener(_customerInfoController.add);
      _isConfigured = true;
    } on Exception catch (error) {
      debugPrint('PurchasesService: failed to configure RevenueCat: $error');
    }
  }

  /// Identifies the RevenueCat user as [appUserId] (the Supabase user id).
  ///
  /// Call this whenever the authenticated user changes.
  Future<void> logIn(String appUserId) async {
    if (!_isConfigured) return;
    try {
      final result = await Purchases.logIn(appUserId);
      _customerInfoController.add(result.customerInfo);
    } on Exception catch (error) {
      debugPrint('PurchasesService: logIn failed: $error');
    }
  }

  /// Whether the current user has the active `premium` entitlement.
  Future<bool> isPremium() async {
    if (!_isConfigured) return false;
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return hasPremiumEntitlement(customerInfo);
    } on Exception catch (error) {
      debugPrint('PurchasesService: isPremium check failed: $error');
      return false;
    }
  }

  /// Fetches the RevenueCat offerings, or `null` when billing is disabled.
  Future<Offerings?> getOfferings() async {
    if (!_isConfigured) return null;
    return Purchases.getOfferings();
  }

  /// Convenience getter for the packages of the current offering.
  Future<List<Package>> getAvailablePackages() async {
    final offerings = await getOfferings();
    return offerings?.current?.availablePackages ?? const <Package>[];
  }

  /// Purchases [package] and returns the updated [CustomerInfo].
  ///
  /// Throws [BillingUnavailableException] when billing is disabled and
  /// rethrows store errors (use [isUserCancellation] to detect cancels).
  Future<CustomerInfo> purchasePackage(Package package) async {
    if (!_isConfigured) throw const BillingUnavailableException();
    final result = await Purchases.purchase(PurchaseParams.package(package));
    return result.customerInfo;
  }

  /// Restores previous purchases and returns the updated [CustomerInfo].
  Future<CustomerInfo> restorePurchases() async {
    if (!_isConfigured) throw const BillingUnavailableException();
    return Purchases.restorePurchases();
  }
}
