import '../../domain/entities/user_entity.dart';

/// User model for JSON serialization
class UserModel {
  final String email;
  final String fullName;
  final String role;
  final String? studentId;
  final String? phone;
  final String? department;
  final String? bio;

  const UserModel({
    required this.email,
    required this.fullName,
    required this.role,
    this.studentId,
    this.phone,
    this.department,
    this.bio,
  });

  /// From JSON (matches /auth/me response)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      role: json['role'] ?? 'student',
      studentId: json['student_id'] ?? json['studentId'],
      phone: json['phone'],
      department: json['department'],
      bio: json['bio'],
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'full_name': fullName,
      'role': role,
      'student_id': studentId,
      'phone': phone,
      'department': department,
      'bio': bio,
    };
  }

  /// Convert to Entity
  UserEntity toEntity({String? token}) {
    return UserEntity(
      id: email,
      email: email,
      fullName: fullName,
      role: role,
      studentId: studentId,
      phone: phone,
      department: department,
      bio: bio,
      token: token,
    );
  }
}

/// Login request body
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}

/// Login response from /auth/login
class LoginResponse {
  final String accessToken;
  final String tokenType;
  final UserModel user;

  LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'] ?? '',
      tokenType: json['token_type'] ?? 'bearer',
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }
}