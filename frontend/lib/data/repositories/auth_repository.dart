import 'package:belaraby/data/supabase_client.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show UserAttributes;

/// Owns the app's Supabase auth identity.
///
/// Every user gets an anonymous Supabase user so favorites, learned lessons
/// and subscriptions can be persisted server-side, and so purchases can be
/// attributed to the Supabase user id in RevenueCat.
class AuthRepository {
  /// Returns the current Supabase user id, signing in anonymously first
  /// when no session exists yet.
  ///
  /// Returns `null` when sign-in fails (e.g. the device is offline); safe to
  /// call repeatedly — callers should retry before identity-critical
  /// operations such as purchases.
  Future<String?> ensureSignedIn() async {
    final currentId = supabase.auth.currentUser?.id;
    if (currentId != null) return currentId;
    try {
      final response = await supabase.auth.signInAnonymously();
      return response.user?.id;
    } on Exception catch (error) {
      debugPrint('AuthRepository.ensureSignedIn failed: $error');
      return null;
    }
  }

  /// Whether the current session belongs to an anonymous (guest) user.
  bool get isAnonymous => supabase.auth.currentUser?.isAnonymous ?? true;

  /// Email of the signed-in user, or `null` for guests.
  String? get currentEmail => supabase.auth.currentUser?.email;

  /// Signs in to an existing email/password account.
  ///
  /// Replaces the anonymous session; the signed-in account's own
  /// favorites/learned/subscription take over. Throws `AuthException` on
  /// bad credentials.
  Future<void> signIn({required String email, required String password}) {
    return supabase.auth.signInWithPassword(email: email, password: password);
  }

  /// Creates an account by UPGRADING the current anonymous user with an
  /// email and password — the user keeps their id, so favorites, learned
  /// lessons and purchases carry over. Throws `AuthException` when the
  /// email is already registered or the password is rejected.
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    await ensureSignedIn();
    await supabase.auth.updateUser(
      UserAttributes(email: email, password: password),
    );
  }

  /// Sends a password-recovery email. On web the link returns to the app
  /// origin (must be in the Auth redirect allow-list); supabase_flutter
  /// picks the token out of the URL and emits a passwordRecovery event.
  Future<void> sendPasswordReset(String email) {
    return supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: kIsWeb ? Uri.base.origin : null,
    );
  }

  /// Sets a new password for the signed-in user (used by the recovery
  /// flow after the email link established a session).
  Future<void> updatePassword(String password) async {
    await supabase.auth.updateUser(UserAttributes(password: password));
  }

  /// Signs out and immediately starts a fresh anonymous session so the
  /// app keeps working (favorites etc. need an identity).
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } on Exception catch (error) {
      debugPrint('AuthRepository.signOut failed: $error');
    }
    await ensureSignedIn();
  }

  /// Permanently deletes the caller's account.
  ///
  /// Invokes the `delete-account` edge function, which derives the user id
  /// from the JWT and deletes the auth user with the service-role admin API
  /// (FK cascades clean up profiles/favorites/learned/subscriptions). Then
  /// signs out locally and starts a fresh anonymous session.
  ///
  /// Throws when the edge function call fails; the local sign-out and the
  /// new anonymous session are best-effort after a successful deletion.
  Future<void> deleteAccount() async {
    await supabase.functions.invoke('delete-account');
    try {
      await supabase.auth.signOut();
    } on Exception catch (error) {
      // The server-side user is already gone; the stale local session is
      // unusable either way, so keep going and start a fresh identity.
      debugPrint('AuthRepository.deleteAccount: signOut failed: $error');
    }
    await ensureSignedIn();
  }
}
