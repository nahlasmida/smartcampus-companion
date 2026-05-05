import '../../domain/repositories/profile_repository.dart';
import '../remote/profile_remote_datasource.dart';
import '../models/user_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl({required ProfileRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<UserModel> getProfile(String token) async {
    return await _remoteDataSource.getProfile(token);
  }

  @override
  Future<UserModel> updateProfile(String token, Map<String, dynamic> data) async {
    return await _remoteDataSource.updateProfile(token, data);
  }
}