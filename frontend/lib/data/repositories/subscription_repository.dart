import 'package:belaraby/data/supabase_client.dart';

/// Server-side subscription state (the source of truth for content gating).
///
/// RevenueCat handles the store purchase flow on mobile; this repository
/// covers the parts that talk to our own backend: the premium check used on
/// web (where the RevenueCat plugin doesn't exist) and the demo
/// subscription endpoint.
class SubscriptionRepository {
  /// Whether the current user has an active subscription row server-side
  /// (`expires_at > now()` — the same gate that unmasks paid story bodies).
  Future<bool> hasActiveSubscription() async {
    final result = await supabase.rpc<bool>('has_active_subscription');
    return result;
  }

  /// Toggles the REAL demo subscription via the `demo-subscription` edge
  /// function. Only allowlisted demo accounts are accepted (403 otherwise).
  /// Returns the new subscribed state.
  Future<bool> setDemoSubscription({required bool subscribe}) async {
    final response = await supabase.functions.invoke(
      'demo-subscription',
      body: {'action': subscribe ? 'subscribe' : 'unsubscribe'},
    );
    final data = response.data as Map<String, dynamic>?;
    return (data?['subscribed'] as bool?) ?? subscribe;
  }
}
