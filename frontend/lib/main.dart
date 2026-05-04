import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_campus_companion/core/routes/app_routes.dart';
import 'package:smart_campus_companion/core/routes/route_generator.dart';
import 'package:smart_campus_companion/core/theme/app_theme.dart';
import 'package:smart_campus_companion/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();

  runApp(
    const ProviderScope(
      child: SmartCampusCompanion(),
    ),
  );
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
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}