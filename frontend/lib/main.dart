import 'dart:async';

import 'package:belaraby/app/app.dart';
import 'package:belaraby/app/settings/view/new_password_page.dart';
import 'package:belaraby/data/repositories/auth_repository.dart';
import 'package:belaraby/data/services/purchases_service.dart';
import 'package:belaraby/data/supabase_client.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthChangeEvent, Supabase;

/// Entry point of the application.
///
/// Initializes critical services before running the app:
/// 1. [WidgetsFlutterBinding] for engine communication.
/// 2. [EasyLocalization] for i18n support.
/// 3. [Supabase] for backend services (+ anonymous sign-in).
/// 4. [PurchasesService] for RevenueCat billing.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Detect a password-recovery link BEFORE Supabase.initialize consumes the
  // URL: with the PKCE flow the recovery event fires during initialization
  // — earlier than any listener can be attached — so the deep link must be
  // captured here. Recovery links carry a `flow=recovery` marker (set in
  // AuthRepository.sendPasswordReset) to distinguish them from OAuth
  // redirects, which also use a `code` param.
  final isRecoveryLink =
      kIsWeb &&
      (Uri.base.queryParameters['flow'] == 'recovery' ||
          Uri.base.fragment.contains('type=recovery'));

  // Initialize easy_localization
  await EasyLocalization.ensureInitialized();

  // Initialize Supabase
  // Values are injected at build time via --dart-define.
  // See DEPLOYMENT.md for per-environment values.
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw StateError(
      'SUPABASE_URL / SUPABASE_ANON_KEY dart-defines are missing. '
      'Launch via a "frontend (local …)" configuration in VS Code, or run: '
      'flutter run --dart-define=SUPABASE_URL=… '
      '--dart-define=SUPABASE_ANON_KEY=… (see DEPLOYMENT.md §4).',
    );
  }
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  // Every user gets an (anonymous) Supabase identity so favorites, learned
  // lessons and subscriptions can be persisted server-side. A failure here
  // (e.g. offline first boot) is not fatal: SubscriptionCubit retries the
  // sign-in before any purchase/restore, and LibraryRepository retries it
  // before every favorites/learned operation, so the session self-heals
  // once connectivity returns.
  await AuthRepository().ensureSignedIn();

  // RevenueCat keys are injected via --dart-define
  // (REVENUECAT_APPLE_API_KEY / REVENUECAT_GOOGLE_API_KEY). Without keys
  // the service is a no-op and the app runs with billing disabled.
  final purchasesService = PurchasesService();
  await purchasesService.init(appUserId: supabase.auth.currentUser?.id);

  // Keep downstream services in sync with the auth identity.
  supabase.auth.onAuthStateChange.listen((authState) {
    final userId = authState.session?.user.id;
    if (userId != null) {
      unawaited(purchasesService.logIn(userId));
    }
    // Session invalidated server-side (e.g. the refresh token no longer
    // exists after a DB reset or account deletion): the SDK clears the
    // session and emits signedOut. Start a fresh anonymous identity so the
    // app keeps working instead of issuing unauthenticated queries.
    if (authState.event == AuthChangeEvent.signedOut) {
      unawaited(AuthRepository().ensureSignedIn());
    }
    // Password-recovery link opened (web): the URL token established a
    // session; prompt for the new password.
    if (authState.event == AuthChangeEvent.passwordRecovery) {
      unawaited(
        appNavigatorKey.currentState?.push(
          MaterialPageRoute<void>(builder: (_) => const NewPasswordPage()),
        ) ??
            Future<void>.value(),
      );
    }
  });

  if (isRecoveryLink) {
    // Open the new-password form once the navigator exists.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        appNavigatorKey.currentState?.push(
              MaterialPageRoute<void>(
                builder: (_) => const NewPasswordPage(),
              ),
            ) ??
            Future<void>.value(),
      );
    });
  }

  runApp(
    EasyLocalization(
      // Arabic-only by design — the learning content and UI are Arabic.
      supportedLocales: const [Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      child: BelArabyApp(purchasesService: purchasesService),
    ),
  );
}
