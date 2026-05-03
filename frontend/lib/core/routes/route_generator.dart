import 'package:flutter/material.dart';
import 'package:smart_campus_companion/core/routes/app_routes.dart';
import 'package:smart_campus_companion/presentation/screens/splash_screen.dart';
import 'package:smart_campus_companion/presentation/screens/login_screen.dart';
import 'package:smart_campus_companion/presentation/screens/register_screen.dart';  // ← ADD THIS

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.register:  // ← ADD THIS CASE
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case AppRoutes.home:
      // TODO: Create HomeScreen
        return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('Home Screen'))));
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}