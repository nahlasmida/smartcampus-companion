import '../../data/models/user_model.dart';

abstract class ProfileRepository {
  Future<UserModel> getProfile(String token);
  Future<UserModel> updateProfile(String token, Map<String, dynamic> data);
}