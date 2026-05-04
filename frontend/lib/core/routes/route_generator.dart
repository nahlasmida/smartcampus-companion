import 'package:flutter/material.dart';
import 'package:smart_campus_companion/core/routes/app_routes.dart';
import 'package:smart_campus_companion/presentation/screens/splash_screen.dart';
import 'package:smart_campus_companion/presentation/screens/login_screen.dart';
import 'package:smart_campus_companion/presentation/screens/home_screen.dart';
import 'package:smart_campus_companion/presentation/screens/timetable_screen.dart';
import 'package:smart_campus_companion/presentation/screens/map_screen.dart';

import '../../presentation/screens/announcements_screen.dart';
import '../../presentation/screens/events_screen.dart';
import '../../presentation/screens/register_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen()); // ← ADD THIS
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case AppRoutes.timetable:
        return MaterialPageRoute(builder: (_) => const TimetableScreen());

      case AppRoutes.campusMap:
        return MaterialPageRoute(builder: (_) => const MapScreen());
      case AppRoutes.announcements:
        return MaterialPageRoute(builder: (_) => const AnnouncementsScreen());
      case AppRoutes.events:
        return MaterialPageRoute(builder: (_) => const EventsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}