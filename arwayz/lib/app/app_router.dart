import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../splash_page.dart';
import '../features/home/home_page.dart';
import '../navigation_selector_page.dart';
import '../outdoor_navigation_page.dart';
import '../admin_login_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const MyHomePage(title: 'ARWayz'),
      ),
      GoRoute(
        path: '/explore',
        name: 'explore',
        builder: (context, state) => const NavigationSelectorPage(),
      ),
      GoRoute(
        path: '/outdoor',
        name: 'outdoor',
        builder: (context, state) => const OutdoorNavigationPage(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminLoginPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(child: Text('Navigation error: ${state.error}')),
    ),
  );
}
