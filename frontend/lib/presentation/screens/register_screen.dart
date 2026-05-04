import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/color_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/validation_utils.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/remote/auth_remote_datasource.dart';
import '../../data/local/auth_local_datasource.dart';
import '../../domain/impl/auth_repository_impl.dart';

// ==================== PROVIDER ====================

final registerRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: AuthRemoteDataSource(),
    localDataSource: AuthLocalDataSource(),
  );
});

// ==================== REGISTER SCREEN ====================

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _formController;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _generalError;

  // Validation errors
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _fullNameError;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _formController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _formController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _studentIdController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _emailError = ValidationUtils.validateEmail(_emailController.text);
      _passwordError = ValidationUtils.validatePassword(_passwordController.text);
      _fullNameError = ValidationUtils.validateName(_fullNameController.text);

      if (_passwordController.text != _confirmPasswordController.text) {
        _confirmPasswordError = 'Passwords do not match';
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  bool get _isFormValid {
    return _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null &&
        _fullNameError == null &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _fullNameController.text.isNotEmpty &&
        _passwordController.text == _confirmPasswordController.text;
  }

  Future<void> _register() async {
    _validateForm();

    if (!_isFormValid) {
      return;
    }

    setState(() {
      _isLoading = true;
      _generalError = null;
    });

    try {
      final authRepository = ref.read(registerRepositoryProvider);

      print('📝 Attempting registration...');
      print('📧 Email: ${_emailController.text.trim()}');
      print('👤 Full Name: ${_fullNameController.text.trim()}');

      await authRepository.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        studentId: _studentIdController.text.isEmpty ? null : _studentIdController.text.trim(),
        phone: _phoneController.text.isEmpty ? null : _phoneController.text.trim(),
        department: _departmentController.text.isEmpty ? null : _departmentController.text.trim(),
      );

      print('✅ Registration successful!');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Please login.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } catch (e) {
      print('❌ Registration failed: $e');
      setState(() {
        _generalError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.splashGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Logo with bounce animation
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    final bounceValue = CurvedAnimation(
                      parent: _logoController,
                      curve: Curves.elasticOut,
                    ).value;
                    return Transform.scale(
                      scale: 0.5 + (bounceValue * 0.5),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.darkNavy.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.person_add_rounded,
                          size: 45,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Title
                Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign up to get started',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.white.withOpacity(0.85),
                  ),
                ),

                const SizedBox(height: 40),

                // Form with slide-up animation
                AnimatedBuilder(
                  animation: _formController,
                  builder: (context, child) {
                    final slideValue = Tween<double>(begin: 0.3, end: 0).animate(
                      CurvedAnimation(parent: _formController, curve: Curves.easeOutCubic),
                    ).value;
                    return Transform.translate(
                      offset: Offset(0, slideValue * 100),
                      child: Opacity(
                        opacity: 1.0 - (slideValue * 1.5).clamp(0.0, 1.0),
                        child: Column(
                          children: [
                            // Full Name
                            _buildTextField(
                              controller: _fullNameController,
                              label: 'Full Name',
                              hint: 'John Doe',
                              icon: Icons.person_outline,
                              errorText: _fullNameError,
                              onChanged: _validateForm,
                            ),
                            const SizedBox(height: 16),

                            // Email
                            _buildTextField(
                              controller: _emailController,
                              label: 'Email',
                              hint: 'your.email@university.edu',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              errorText: _emailError,
                              onChanged: _validateForm,
                            ),
                            const SizedBox(height: 16),

                            // Password
                            _buildTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: '••••••••',
                              icon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              errorText: _passwordError,
                              onChanged: _validateForm,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.white.withOpacity(0.7),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Confirm Password
                            _buildTextField(
                              controller: _confirmPasswordController,
                              label: 'Confirm Password',
                              hint: '••••••••',
                              icon: Icons.lock_outline,
                              obscureText: _obscureConfirmPassword,
                              errorText: _confirmPasswordError,
                              onChanged: _validateForm,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.white.withOpacity(0.7),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Student ID (Optional)
                            _buildTextField(
                              controller: _studentIdController,
                              label: 'Student ID (Optional)',
                              hint: 'e.g., 3432432301',
                              icon: Icons.badge_outlined,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),

                            // Phone (Optional)
                            _buildTextField(
                              controller: _phoneController,
                              label: 'Phone (Optional)',
                              hint: 'e.g., 0666343294',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),

                            // Department (Optional)
                            _buildTextField(
                              controller: _departmentController,
                              label: 'Department (Optional)',
                              hint: 'e.g., Computer Science, IFA',
                              icon: Icons.school_outlined,
                            ),
                            const SizedBox(height: 16),

                            // Bio (Optional)
                            _buildTextField(
                              controller: _bioController,
                              label: 'Bio (Optional)',
                              hint: 'Tell us about yourself...',
                              icon: Icons.description_outlined,
                              maxLines: 2,
                            ),

                            const SizedBox(height: 24),

                            // Error Message
                            if (_generalError != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline, color: Colors.red.shade200, size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _generalError!,
                                        style: TextStyle(color: Colors.red.shade200, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 24),

                            // Register Button
                            _buildRegisterButton(),

                            const SizedBox(height: 24),

                            // Login Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Already have an account? ",
                                  style: TextStyle(color: AppColors.white.withOpacity(0.8)),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                                  },
                                  child: Text(
                                    'Sign In',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? errorText,
    VoidCallback? onChanged,
    Widget? suffixIcon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.white.withOpacity(0.9),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: (_) => onChanged?.call(),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.white.withOpacity(0.5)),
            prefixIcon: Icon(icon, color: AppColors.white.withOpacity(0.7), size: 22),
            suffixIcon: suffixIcon,
            errorText: errorText,
            filled: true,
            fillColor: AppColors.navy.withOpacity(0.7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.white.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading || !_isFormValid ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [AppColors.primary, AppColors.secondary],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: _isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
                : const Text(
              'Create Account',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}