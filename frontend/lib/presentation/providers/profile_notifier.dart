import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/remote/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../services/secure_storage.dart';
import 'profile_state.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    remoteDataSource: ProfileRemoteDataSource(),
  );
});

final profileNotifierProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  final storage = ref.watch(secureStorageProvider); // ← FIXED: Use secureStorageProvider
  return ProfileNotifier(repository, storage);
});

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;
  final FlutterSecureStorage _storage; // ← FIXED: Use FlutterSecureStorage directly

  ProfileNotifier(this._repository, this._storage) : super(const ProfileState()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final token = await _storage.read(key: 'access_token'); // ← FIXED: read directly
      if (token == null) throw Exception('Not authenticated');

      final user = await _repository.getProfile(token);
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load profile',
      );
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final token = await _storage.read(key: 'access_token'); // ← FIXED: read directly
      if (token == null) throw Exception('Not authenticated');

      final updatedUser = await _repository.updateProfile(token, data);
      state = state.copyWith(isSaving: false, user: updatedUser, isEditing: false);
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Failed to update profile',
      );
    }
  }

  void toggleEditing() {
    state = state.copyWith(isEditing: !state.isEditing);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}