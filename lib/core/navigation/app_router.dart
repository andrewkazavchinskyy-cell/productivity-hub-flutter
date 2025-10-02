import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/ai/presentation/pages/ai_page.dart';
import '../../features/calendar/presentation/pages/calendar_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

enum AppRoute {
  home('home'),
  calendar('calendar'),
  assistant('assistant'),
  settings('settings');

  const AppRoute(this.name);
  final String name;
}

class AppRouter {
  AppRouter() {
    router = GoRouter(
      routes: [
        GoRoute(
          name: AppRoute.home.name,
          path: '/',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          name: AppRoute.calendar.name,
          path: '/calendar',
          builder: (context, state) => const CalendarPage(),
        ),
        GoRoute(
          name: AppRoute.assistant.name,
          path: '/assistant',
          builder: (context, state) => const AiPage(),
        ),
        GoRoute(
          name: AppRoute.settings.name,
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
      ],
      initialLocation: '/calendar',
      debugLogDiagnostics: false,
      errorBuilder: (context, state) {
        return Scaffold(
          body: Center(
            child: Text('Страница не найдена: ${state.error}'),
          ),
        );
      },
    );
  }

  late final GoRouter router;
}
