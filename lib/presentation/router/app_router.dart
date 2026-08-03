import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pages/game_page.dart';
import '../pages/home_page.dart';

/// Application routes.
class AppRoutes {
  static const home = '/';
  static const game = '/game';
}

/// Create the application router.
GoRouter createRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.game,
        name: 'game',
        builder: (context, state) => const GamePage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}
