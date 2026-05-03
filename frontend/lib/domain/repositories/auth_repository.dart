import '../entities/user_entity.dart';

/// Abstract contract for authentication
abstract class AuthRepository {
  /// Login with email and password
  Future<UserEntity> login(String email, String password);

  /// Register a new user
  Future<UserEntity> register({
    required String email,
    required String password,
    required String fullName,
    String? studentId,
    String? phone,
    String? department,
  });

  /// Get current logged in user (with stored token)
  Future<UserEntity?> getCurrentUser();

  /// Check if user is logged in
  Future<bool> isLoggedIn();

  /// Logout - clear stored tokens
  Future<void> logout();

  /// Check if biometric is available on device
  Future<bool> isBiometricAvailable();

  /// Authenticate with biometrics (fingerprint/face)
  Future<bool> authenticateWithBiometrics();

  /// Save biometric opt-in preference
  Future<void> setBiometricOptIn(bool enabled);

  /// Get biometric opt-in preference
  Future<bool> getBiometricOptIn();
}