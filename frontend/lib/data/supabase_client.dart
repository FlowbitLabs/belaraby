import 'package:supabase_flutter/supabase_flutter.dart';

/// The app-wide Supabase client.
///
/// Always use this instance (never instantiate a new client); it is backed
/// by [Supabase.initialize] in `main()` and carries the auth session.
final SupabaseClient supabase = Supabase.instance.client;
