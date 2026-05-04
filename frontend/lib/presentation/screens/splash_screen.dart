import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_campus_companion/core/constants/color_constants.dart';
import 'package:smart_campus_companion/core/routes/app_routes.dart';
import 'package:smart_campus_companion/presentation/widgets/campus_illustration.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    _controller = AnimationController(
      duration: const Duration(milliseconds: 20),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
        begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 10));
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.splashGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
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
                    const SizedBox(height: 24),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) {
                              return const LinearGradient(
                                colors: [AppColors.white, AppColors.primary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds);
                            },
                            child: Text(
                              'Navigate Campus',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SlideTransition(
                            position: _slideAnimation,
                            child: Text(
                              'Find your way around with interactive maps\nand building locations',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.white.withOpacity(0.85),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primary),
                      backgroundColor: AppColors.white.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Opacity(
                      opacity: 0.15,
                      child: CustomPaint(
                        painter: CampusIllustration(),
                        size: MediaQuery.of(context).size,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}