class ProfileModel {
  final String id;
  final String username;
  final String email;
  final String? avatar_url;
  final String? role;
  // final DateTime created_at; default value : date.now()


  ProfileModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatar_url,
    this.role,
    // this.created_at = ,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      avatar_url: json['avatar_url'] as String,
      role: json['role'] as String,
      // created_at: json['created_at'] as DateTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar_url': avatar_url,
      'role': role,
      // 'created_at': created_at,
    };
  }
}



