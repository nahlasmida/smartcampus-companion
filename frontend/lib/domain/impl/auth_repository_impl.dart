import 'dart:convert';
import 'package:local_auth/local_auth.dart';
import '../../data/local/auth_local_datasource.dart';
import '../../data/remote/auth_remote_datasource.dart';
import '../../data/models/user_model.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final LocalAuthentication _localAuth;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    LocalAuthentication? localAuth,
  }) : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _localAuth = localAuth ?? LocalAuthentication();

  @override
  Future<UserEntity> login(String email, String password) async {
    final response = await _remoteDataSource.login(email, password);
    await _localDataSource.saveToken(response.accessToken);
    final userJson = jsonEncode(response.user.toJson());
    await _localDataSource.saveUser(userJson);
    return response.user.toEntity(token: response.accessToken);
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String fullName,
    String? studentId,
    String? phone,
    String? department,
  }) async {
    await _remoteDataSource.register(
      email: email,
      password: password,
      fullName: fullName,
      studentId: studentId,
      phone: phone,
      department: department,
    );
    return await login(email, password);
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final token = await _localDataSource.getToken();
    if (token == null) return null;
    try {
      final user = await _remoteDataSource.getCurrentUser(token);
      return user.toEntity(token: token);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _localDataSource.getToken();
    return token != null;
  }

  @override
  Future<void> logout() async {
    await _localDataSource.clearAll();
  }

  @override
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> authenticateWithBiometrics() async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Verify your identity to login',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return authenticated;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> setBiometricOptIn(bool enabled) async {
    await _localDataSource.setBiometricOptIn(enabled);
  }

  @override
  Future<bool> getBiometricOptIn() async {
    return await _localDataSource.getBiometricOptIn();
  }
}