import 'package:flutter/material.dart';
import 'package:smart_campus_companion/core/routes/app_routes.dart';
import 'package:smart_campus_companion/core/routes/route_generator.dart';  // ← ADD THIS LINE
import 'package:smart_campus_companion/core/theme/app_theme.dart';

void main() {
  runApp(const SmartCampusCompanion());
}

class SmartCampusCompanion extends StatelessWidget {
  const SmartCampusCompanion({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartCampus Companion',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: RouteGenerator.generateRoute,  // ← Now this will work
    );
  }
}