import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/ble/presentation/screens/ble_connection_screen.dart';
import '../../features/measurement/presentation/screens/dashboard_screen.dart';
import '../../features/measurement/presentation/screens/history_screen.dart';
import '../../features/measurement/presentation/screens/live_measurement_screen.dart';
import '../../shared/widgets/main_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    // 1. Standalone Splash Screen (Initial Route)
    GoRoute(
      path: '/splash',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => const MaterialPage(
        child: SplashScreen(),
      ),
    ),

    // 2. Standalone Login Screen
    GoRoute(
      path: '/login',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => const MaterialPage(
        child: LoginScreen(),
      ),
    ),

    // 3. Standalone Register / Create Account Screen
    GoRoute(
      path: '/register',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => const MaterialPage(
        child: RegisterScreen(),
      ),
    ),

    // 4. Authenticated Application Shell (Bottom Navigation Bar)
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/bluetooth',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: BleConnectionScreen(),
          ),
        ),
        GoRoute(
          path: '/live',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: LiveMeasurementScreen(),
          ),
        ),
        GoRoute(
          path: '/history',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HistoryScreen(),
          ),
        ),
      ],
    ),
  ],
);
