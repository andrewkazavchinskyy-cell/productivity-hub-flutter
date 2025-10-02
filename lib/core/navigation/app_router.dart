import 'package:go_router/go_router.dart';
import 'package:productivity_hub/features/home/presentation/pages/home_page.dart';

class AppRouter {
  AppRouter();

  late final GoRouter router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}
