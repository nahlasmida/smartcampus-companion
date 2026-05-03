import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/remote/auth_remote_datasource.dart';
import '../../data/local/auth_local_datasource.dart';
import '../../domain/impl/auth_repository_impl.dart';
import '../../core/utils/validation_utils.dart';
import 'login_state.dart';

// ==================== PROVIDERS ====================

final authRepositoryProvider = Provider<AuthRepository>((ref) {
return AuthRepositoryImpl(
remoteDataSource: AuthRemoteDataSource(),
localDataSource: AuthLocalDataSource(),
);
});

final loginNotifierProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
final authRepository = ref.watch(authRepositoryProvider);
return LoginNotifier(authRepository);
});

// ==================== LOGIN NOTIFIER ====================

class LoginNotifier extends StateNotifier<LoginState> {
final AuthRepository _authRepository;

LoginNotifier(this._authRepository) : super(const LoginState()) {
_checkBiometricAvailability();
}

Future<void> _checkBiometricAvailability() async {
final isAvailable = await _authRepository.isBiometricAvailable();
final optIn = await _authRepository.getBiometricOptIn();
state = state.copyWith(
isBiometricAvailable: isAvailable,
biometricOptIn: optIn,
);
}

void onEmailChanged(String email) {
print('📧 Email changed to: "$email"');
// TEMPORARILY SKIP VALIDATION FOR TESTING
// final error = ValidationUtils.validateEmail(email);
state = state.copyWith(
email: email,
emailError: null,  // ← FORCE NO ERROR
generalError: null,
);
print('📧 IsValid after change: ${state.isValid}');
}

void onPasswordChanged(String password) {
print('🔑 Password changed, length: ${password.length}');
// TEMPORARILY SKIP VALIDATION FOR TESTING
// final error = ValidationUtils.validatePassword(password);
state = state.copyWith(
password: password,
passwordError: null,  // ← FORCE NO ERROR
generalError: null,
);
print('🔑 IsValid after change: ${state.isValid}');
}

void togglePasswordVisibility() {
state = state.copyWith(obscurePassword: !state.obscurePassword);
}

Future<bool> login() async {
print('========================================');
print('🔐 LOGIN BUTTON PRESSED');
print('📧 Current email: ${state.email}');
print('🔑 Current password length: ${state.password?.length ?? 0}');
print('========================================');

// TEMPORARILY SKIP VALIDATION FOR TESTING
// final emailError = ValidationUtils.validateEmail(state.email);
// final passwordError = ValidationUtils.validatePassword(state.password);

// FORCE NO VALIDATION ERRORS
final emailError = null;
final passwordError = null;

if (emailError != null || passwordError != null) {
print('❌ Validation failed: emailError=$emailError, passwordError=$passwordError');
state = state.copyWith(
emailError: emailError,
passwordError: passwordError,
);
return false;
}

// Check if email and password are not empty
if (state.email == null || state.email!.isEmpty) {
print('❌ Email is empty');
state = state.copyWith(
generalError: 'Please enter your email',
);
return false;
}

if (state.password == null || state.password!.isEmpty) {
print('❌ Password is empty');
state = state.copyWith(
generalError: 'Please enter your password',
);
return false;
}

// Start loading
state = state.copyWith(isLoading: true, generalError: null);

try {
print('🚀 Calling login API...');
print('📧 Email: ${state.email!.trim()}');
print('🔑 Password: ${state.password}');

final user = await _authRepository.login(
state.email!.trim(),
state.password!,
);

print('✅ Login successful! User: ${user.email}');
state = state.copyWith(
isLoading: false,
user: user,
generalError: null,
);
return true;
} catch (e) {
print('❌ Login failed: $e');

String errorMessage = e.toString();
// Clean up the error message
errorMessage = errorMessage.replaceAll('Exception: ', '');
errorMessage = errorMessage.replaceAll('DioException: ', '');

state = state.copyWith(
isLoading: false,
generalError: errorMessage,
);
return false;
}
}

Future<bool> loginWithBiometrics() async {
if (!state.isBiometricAvailable) {
state = state.copyWith(
generalError: 'Biometric authentication is not available',
);
return false;
}

state = state.copyWith(isLoading: true, generalError: null);

try {
final authenticated = await _authRepository.authenticateWithBiometrics();
if (!authenticated) {
state = state.copyWith(
isLoading: false,
generalError: 'Biometric authentication failed',
);
return false;
}

final hasStoredToken = await _authRepository.isLoggedIn();
if (!hasStoredToken) {
state = state.copyWith(
isLoading: false,
generalError: 'No saved login found',
);
return false;
}

final user = await _authRepository.getCurrentUser();
if (user == null) {
state = state.copyWith(
isLoading: false,
generalError: 'Session expired',
);
return false;
}

state = state.copyWith(isLoading: false, user: user);
return true;
} catch (e) {
state = state.copyWith(
isLoading: false,
generalError: 'Biometric login failed: ${e.toString()}',
);
return false;
}
}

void clearError() {
state = state.copyWith(generalError: null);
}
}