import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../splash_page.dart';
import '../features/home/home_page.dart';
import '../navigation_selector_page.dart';
import '../outdoor_navigation_page.dart';
import '../admin_login_page.dart';
import '../features/events/events_page.dart';
import '../indoor_navigation_page.dart';
import '../qr_payload.dart';

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
