class UserProfile {
  final String username;
  final String role;
  final bool status;
  final String message;

  UserProfile({
    required this.username,
    required this.role,
    required this.status,
    required this.message,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'] ?? 'Unknown User',
      role: json['role'] ?? 'user', 
      status: json['status'] ?? false,
      message: json['message'] ?? 'Unknown status.',
    );
  }

  String getRole() {
    return role;
  }

  bool isLoggedIn() {
    return status && username != 'guest';
  }
}