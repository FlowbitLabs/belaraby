import 'package:belaraby/data/supabase_client.dart';

/// The current user's `profiles` row (username etc.).
///
/// RLS restricts reads/writes to the caller's own row; the `is_admin`
/// column is protected server-side by a trigger.
class ProfileRepository {
  /// Returns the user's username, or null when unset / signed out.
  Future<String?> fetchUsername() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;
    final row = await supabase
        .from('profiles')
        .select('username')
        .eq('id', userId)
        .maybeSingle();
    return row?['username'] as String?;
  }

  /// Saves the username on the user's profile row (upserts in case the
  /// profile trigger has not created the row yet).
  Future<void> updateUsername(String username) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    await supabase.from('profiles').upsert({
      'id': userId,
      'username': username,
    });
  }
}
