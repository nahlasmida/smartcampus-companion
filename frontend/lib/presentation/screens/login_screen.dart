import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/color_constants.dart';
import '../../core/routes/app_routes.dart';
import '../providers/login_notifier.dart';
import '../providers/login_state.dart';
import '../widgets/animated_text_field.dart';
import '../widgets/biometric_button.dart';
import '../widgets/gradient_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _headerController;
  late AnimationController _formController;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
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
    _headerController.dispose();
    _formController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginNotifierProvider);
    final loginNotifier = ref.read(loginNotifierProvider.notifier);

    // Sync controllers with state
    if (_emailController.text != (loginState.email ?? '')) {
      _emailController.text = loginState.email ?? '';
    }
    if (_passwordController.text != (loginState.password ?? '')) {
      _passwordController.text = loginState.password ?? '';
    }

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
                const SizedBox(height: 40),

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
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.darkNavy.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.explore_rounded,
                          size: 56,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // Welcome text with slide animation
                AnimatedBuilder(
                  animation: _headerController,
                  builder: (context, child) {
                    final slideValue = Tween<double>(begin: -0.3, end: 0).animate(
                      CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic),
                    ).value;
                    return Transform.translate(
                      offset: Offset(0, slideValue * 100),
                      child: Opacity(
                        opacity: 1.0 - (slideValue.abs()),
                        child: Column(
                          children: [
                            Text(
                              'Welcome Back',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sign in to continue',
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.white.withOpacity(0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 48),

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
                            // Email Field
                            AnimatedTextField(
                              label: 'Email',
                              hint: 'your.email@university.edu',
                              controller: _emailController,
                              errorText: loginState.emailError,
                              onChanged: loginNotifier.onEmailChanged,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                            ),

                            const SizedBox(height: 20),

                            // Password Field
                            AnimatedTextField(
                              label: 'Password',
                              hint: 'Enter your password',
                              controller: _passwordController,
                              errorText: loginState.passwordError,
                              onChanged: loginNotifier.onPasswordChanged,
                              obscureText: loginState.obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  loginState.obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.white.withOpacity(0.7),
                                ),
                                onPressed: loginNotifier.togglePasswordVisibility,
                              ),
                              textInputAction: TextInputAction.done,
                            ),

                            const SizedBox(height: 12),

                            // Forgot Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // TODO: Implement forgot password
                                  print('Forgot password clicked');
                                },
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: AppColors.white.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Error Message
                            if (loginState.generalError != null)
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
                                        loginState.generalError!,
                                        style: TextStyle(color: Colors.red.shade200, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 24),

                            // Sign In Button
                            GradientButton(
                              text: 'Sign In',
                              isLoading: loginState.isLoading,
                              isEnabled: true,
                              onPressed: () async {
                                print('👆 Sign In button pressed!');
                                final success = await loginNotifier.login();
                                if (success && mounted) {
                                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                                }
                              },
                            ),

                            const SizedBox(height: 24),

                            // OR Divider
                            Row(
                              children: [
                                Expanded(child: Divider(color: AppColors.white.withOpacity(0.3))),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'or',
                                    style: TextStyle(color: AppColors.white.withOpacity(0.6)),
                                  ),
                                ),
                                Expanded(child: Divider(color: AppColors.white.withOpacity(0.3))),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Biometric Button
                            BiometricButton(
                              isAvailable: loginState.isBiometricAvailable,
                              onTap: () async {
                                print('👆 Biometric button pressed');
                                final success = await loginNotifier.loginWithBiometrics();
                                if (success && mounted) {
                                  print('✅ Biometric login successful!');
                                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                                } else {
                                  print('❌ Biometric login failed');
                                }
                              },
                            ),

                            const SizedBox(height: 32),

                            // Sign Up Link - Now navigates to Register Screen
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: TextStyle(color: AppColors.white.withOpacity(0.8)),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    print('👆 Sign Up clicked - navigating to Register');
                                    Navigator.pushNamed(context, AppRoutes.register);
                                  },
                                  child: Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
}