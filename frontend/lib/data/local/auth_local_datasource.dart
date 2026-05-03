import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local storage for auth tokens and preferences
class AuthLocalDataSource {
  static const String _tokenKey = 'access_token';
  static const String _userKey = 'user_data';
  static const String _biometricOptInKey = 'biometric_opt_in';

  final FlutterSecureStorage _secureStorage;

  AuthLocalDataSource({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Save JWT token securely (encrypted)
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  /// Get stored JWT token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  /// Delete token (logout)
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  /// Save user data as JSON string
  Future<void> saveUser(String userJson) async {
    await _secureStorage.write(key: _userKey, value: userJson);
  }

  /// Get stored user data
  Future<String?> getUser() async {
    return await _secureStorage.read(key: _userKey);
  }

  /// Delete user data
  Future<void> deleteUser() async {
    await _secureStorage.delete(key: _userKey);
  }

  /// Save biometric opt-in preference
  Future<void> setBiometricOptIn(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricOptInKey, enabled);
  }

  /// Get biometric opt-in preference
  Future<bool> getBiometricOptIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricOptInKey) ?? false;
  }

  /// Clear all auth data (logout)
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_biometricOptInKey);
  }
}