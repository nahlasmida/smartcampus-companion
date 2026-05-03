import '../../domain/entities/user_entity.dart';

class LoginState {
  final bool isLoading;
  final bool isBiometricAvailable;
  final bool biometricOptIn;
  final String? email;
  final String? password;
  final String? emailError;
  final String? passwordError;
  final String? generalError;
  final UserEntity? user;
  final bool obscurePassword;

  const LoginState({
    this.isLoading = false,
    this.isBiometricAvailable = false,
    this.biometricOptIn = false,
    this.email,
    this.password,
    this.emailError,
    this.passwordError,
    this.generalError,
    this.user,
    this.obscurePassword = true,
  });

  bool get isValid =>
      email != null &&
          password != null &&
          email!.isNotEmpty &&
          password!.length >= 6 &&
          emailError == null &&
          passwordError == null;

  LoginState copyWith({
    bool? isLoading,
    bool? isBiometricAvailable,
    bool? biometricOptIn,
    String? email,
    String? password,
    String? emailError,
    String? passwordError,
    String? generalError,
    UserEntity? user,
    bool? obscurePassword,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isBiometricAvailable: isBiometricAvailable ?? this.isBiometricAvailable,
      biometricOptIn: biometricOptIn ?? this.biometricOptIn,
      email: email ?? this.email,
      password: password ?? this.password,
      emailError: emailError ?? this.emailError,
      passwordError: passwordError ?? this.passwordError,
      generalError: generalError ?? this.generalError,
      user: user ?? this.user,
      obscurePassword: obscurePassword ?? this.obscurePassword,
    );
  }
}