import 'package:dio/dio.dart';
import '../models/user_model.dart';

class ProfileRemoteDataSource {
  final Dio _dio;
  static const String baseUrl = 'http://localhost:8000';

  ProfileRemoteDataSource({Dio? dio}) : _dio = dio ?? Dio();

  Future<UserModel> getProfile(String token) async {
    final response = await _dio.get(
      '$baseUrl/profile/me',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return UserModel.fromJson(response.data);
  }

  Future<UserModel> updateProfile(String token, Map<String, dynamic> data) async {
    final response = await _dio.put(
      '$baseUrl/profile/me',
      data: data,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return UserModel.fromJson(response.data['profile']);
  }
}