// user_model.dart
class UserModel {
  final int userId;
  final String username;
  final String fullName;
  final String? phoneNumber;
  final String? email;
  final int roleId;
  final String? profilePicture;
  final bool isActive;
  final DateTime? lastLogin;

  UserModel({
    required this.userId,
    required this.username,
    required this.fullName,
    this.phoneNumber,
    this.email,
    required this.roleId,
    this.profilePicture,
    required this.isActive,
    this.lastLogin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'],
      username: json['username'],
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      email: json['email'],
      roleId: json['role_id'],
      profilePicture: json['profile_picture'],
      isActive: json['is_active'] == 1,
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'])
          : null,
    );
  }
}