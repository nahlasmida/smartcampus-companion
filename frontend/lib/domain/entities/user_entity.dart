/// Pure Dart entity - no Flutter dependencies
class UserEntity {
  final String id;
  final String email;
  final String fullName;
  final String? studentId;
  final String? phone;
  final String? department;
  final String? bio;
  final String role;
  final String? token;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    this.studentId,
    this.phone,
    this.department,
    this.bio,
    this.role = 'student',
    this.token,
  });

  /// Create a copy with updated fields
  UserEntity copyWith({
    String? id,
    String? email,
    String? fullName,
    String? studentId,
    String? phone,
    String? department,
    String? bio,
    String? role,
    String? token,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      studentId: studentId ?? this.studentId,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }

  @override
  String toString() => 'UserEntity(email: $email, fullName: $fullName, role: $role)';
}