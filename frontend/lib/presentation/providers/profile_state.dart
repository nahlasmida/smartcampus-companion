import '../../data/models/user_model.dart';

class ProfileState {
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final UserModel? user;
  final bool isEditing;

  const ProfileState({
    this.isLoading = true,
    this.isSaving = false,
    this.error,
    this.user,
    this.isEditing = false,
  });

  ProfileState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? error,
    UserModel? user,
    bool? isEditing,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error ?? this.error,
      user: user ?? this.user,
      isEditing: isEditing ?? this.isEditing,
    );
  }
}