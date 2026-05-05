import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_campus_companion/core/constants/color_constants.dart';
import 'package:smart_campus_companion/presentation/providers/profile_notifier.dart';

import '../../data/models/user_model.dart';
import '../providers/profile_state.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _studentIdController;
  late TextEditingController _departmentController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _phoneController = TextEditingController();
    _studentIdController = TextEditingController();
    _departmentController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _studentIdController.dispose();
    _departmentController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _updateControllers(UserModel? user) {
    if (user == null) return;
    _fullNameController.text = user.fullName;
    _phoneController.text = user.phone ?? '';
    _studentIdController.text = user.studentId ?? '';
    _departmentController.text = user.department ?? '';
    _bioController.text = user.bio ?? '';
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'full_name': _fullNameController.text,
        'phone': _phoneController.text.isEmpty ? null : _phoneController.text,
        'student_id': _studentIdController.text.isEmpty ? null : _studentIdController.text,
        'department': _departmentController.text.isEmpty ? null : _departmentController.text,
        'bio': _bioController.text.isEmpty ? null : _bioController.text,
      };
      ref.read(profileNotifierProvider.notifier).updateProfile(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileNotifierProvider);
    final notifier = ref.read(profileNotifierProvider.notifier);

    // Update controllers when user loads
    if (state.user != null && _fullNameController.text.isEmpty) {
      _updateControllers(state.user);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          if (!state.isLoading && state.user != null)
            IconButton(
              icon: Icon(state.isEditing ? Icons.save : Icons.edit),
              onPressed: state.isSaving
                  ? null
                  : () {
                if (state.isEditing) {
                  _saveProfile();
                } else {
                  notifier.toggleEditing();
                }
              },
            ),
        ],
      ),
      body: _buildBody(state, notifier),
    );
  }

  Widget _buildBody(ProfileState state, ProfileNotifier notifier) {
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading profile...'),
          ],
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(state.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => notifier.loadProfile(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.user == null) {
      return const Center(child: Text('No user data'));
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Avatar
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Email (read-only)
          _buildReadOnlyField(
            label: 'Email',
            value: state.user!.email,
            icon: Icons.email_outlined,
          ),
          const SizedBox(height: 16),

          // Full Name
          _buildField(
            label: 'Full Name',
            controller: _fullNameController,
            icon: Icons.person_outline,
            enabled: state.isEditing,
          ),
          const SizedBox(height: 16),

          // Student ID
          _buildField(
            label: 'Student ID',
            controller: _studentIdController,
            icon: Icons.badge_outlined,
            enabled: state.isEditing,
            optional: true,
          ),
          const SizedBox(height: 16),

          // Phone
          _buildField(
            label: 'Phone',
            controller: _phoneController,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            enabled: state.isEditing,
            optional: true,
          ),
          const SizedBox(height: 16),

          // Department
          _buildField(
            label: 'Department',
            controller: _departmentController,
            icon: Icons.school_outlined,
            enabled: state.isEditing,
            optional: true,
          ),
          const SizedBox(height: 16),

          // Bio
          _buildField(
            label: 'Bio',
            controller: _bioController,
            icon: Icons.description_outlined,
            enabled: state.isEditing,
            maxLines: 3,
            optional: true,
          ),

          if (state.isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),

          if (state.error != null && !state.isLoading)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.error!)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
    bool optional = false,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(
          color: enabled ? AppColors.textPrimary : Colors.grey.shade600,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: enabled ? AppColors.primary : Colors.grey.shade500,
          ),
          prefixIcon: Icon(icon, color: enabled ? AppColors.primary : Colors.grey.shade500),
          border: InputBorder.none,
          hintText: optional ? 'Optional' : null,
        ),
        validator: (value) {
          if (!optional && (value == null || value.isEmpty)) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }
}