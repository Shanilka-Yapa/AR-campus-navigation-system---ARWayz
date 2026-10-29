import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../splash_page.dart';
import '../features/welcome/welcome_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/destinations/navigation_selector_page.dart';
import '../features/outdoor_navigation/outdoor_navigation_page.dart';
import '../features/admin/admin_dashboard_page.dart';
import '../features/events/events_page.dart';
import '../features/indoor_navigation/indoor_navigation_page.dart';
import '../core/models/qr_payload.dart';

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
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const DashboardPage(),
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
        builder: (context, state) => const AdminDashboardPage(),
      ),
      GoRoute(
        path: '/events',
        name: 'events',
        builder: (context, state) => const EventsPage(),
      ),
      GoRoute(
        path: '/indoor',
        name: 'indoor',
        builder: (context, state) {
          final startPoint = state.extra;

          if (startPoint is! QrPayload) {
            return const Scaffold(
              body: Center(
                child: Text('Scan a valid QR code to start indoor navigation.'),
              ),
            );
          }

          return IndoorNavigationPage(startPoint: startPoint);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(child: Text('Navigation error: ${state.error}')),
    ),
  );
}
