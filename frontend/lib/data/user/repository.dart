import 'package:belaraby/constant/constants.dart';
import 'package:belaraby/data/supabase_client.dart';

class ProfileRepository {
  Future<void> createProfile(
    String id,
    String username,
    String email,
    String? avatarUrl,
  ) async {
    await supabase
        .from(Constants.profilesTable)
        .insert({
          'id': id,
          'username': username,
          'email': email,
          'avatar_url': avatarUrl,
          'role': null,
        });
  }
}
