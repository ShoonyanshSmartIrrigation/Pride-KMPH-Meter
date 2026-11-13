import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  initialLocation: '/',
  routes: [
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
