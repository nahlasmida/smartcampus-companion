import 'package:dio/dio.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource({Dio? dio}) : _dio = dio ?? Dio();

  // ⚠️ IMPORTANT: Replace with your computer's IP address
  // Run 'ipconfig' in terminal to find your IP
  // Example: 'http://192.168.1.100:8000'
  static const String baseUrl = 'http://localhost:8000'; // ← CHANGE THIS

  /// POST /auth/login
  Future<LoginResponse> login(String email, String password) async {
    try {
      print('🔐 Attempting login to: $baseUrl/auth/login');
      print('📧 Email: $email');

      final response = await _dio.post(
        '$baseUrl/auth/login',
        data: {'email': email, 'password': password},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      print('✅ Response status: ${response.statusCode}');
      print('📦 Response data: ${response.data}');

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(response.data);
      } else {
        throw _handleError(response.statusCode, response.data);
      }
    } on DioException catch (e) {
      print('❌ Dio error: ${e.type}');
      print('❌ Dio message: ${e.message}');
      throw _handleDioError(e);
    }
  }

  /// POST /auth/register
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    String? studentId,
    String? phone,
    String? department,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/auth/register',
        data: {
          'email': email,
          'password': password,
          'full_name': fullName,
          'student_id': studentId,
          'phone': phone,
          'department': department,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw _handleError(response.statusCode, response.data);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// GET /auth/me
  Future<UserModel> getCurrentUser(String token) async {
    try {
      final response = await _dio.get(
        '$baseUrl/auth/me',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw _handleError(response.statusCode, response.data);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleError(int? statusCode, dynamic data) {
    String message = 'An error occurred';
    if (data is Map && data.containsKey('detail')) {
      message = data['detail'].toString();
    }
    switch (statusCode) {
      case 401:
        return Exception('Invalid email or password');  // ← Shows "Invalid email or password"
      case 400:
        return Exception(message);
      default:
        return Exception(message);
    }
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Check your internet.');
      case DioExceptionType.connectionError:
        return Exception('Cannot connect to server. Make sure backend is running.');
      case DioExceptionType.badResponse:
        return _handleError(error.response?.statusCode, error.response?.data);
      default:
        return Exception('Network error: ${error.message}');
    }
  }
}