import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize timezone
  tz.initializeTimeZones();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize dependency injection
  await configureDependencies();
  
  runApp(const ProductivityHubApp());
}

class ProductivityHubApp extends StatelessWidget {
  const ProductivityHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt<AppRouter>();
    
    return MaterialApp.router(
      title: 'Productivity Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter.router,
    );
  }
}
