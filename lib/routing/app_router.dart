/// App Router Configuration
///
/// GoRouter with shell route for bottom navigation.
/// Tab order per 05-navigation.md: Home, Attendance, Calendar, Assignments, Profile.
/// Maximum navigation depth: 3 levels.
///
/// Authentication redirect protects all routes behind login.
/// Splash → Login → Dashboard flow per 08-screen-specifications.md.
///
/// All navigation decisions are centralized in [GoRouter.redirect].
/// UI widgets do not perform navigation for authentication state changes.
library;

import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/authentication/screens/login_screen.dart';
import 'package:college_companion/features/authentication/screens/splash_screen.dart';
import 'package:college_companion/features/dashboard/screens/dashboard_screen.dart';
import 'package:college_companion/routing/scaffold_with_nav_bar.dart';
import 'package:college_companion/shared/widgets/placeholder_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Route path constants.
abstract final class RoutePaths {
  // ── Auth ────────────────────────────────────────────────────────────────
  static const String splash = '/splash';
  static const String login = '/login';

  // ── Root tabs ──────────────────────────────────────────────────────────
  static const String home = '/';
  static const String attendance = '/attendance';
  static const String calendar = '/calendar';
  static const String assignments = '/assignments';
  static const String profile = '/profile';

  // ── Secondary routes ───────────────────────────────────────────────────
  static const String timetable = '/timetable';
  static const String internalMarks = '/internal-marks';
  static const String semester = '/semester';
  static const String settings = '/settings';

  /// Routes that do not require authentication.
  static const List<String> publicRoutes = [splash, login];
}

/// Route name constants for named navigation.
abstract final class RouteNames {
  static const String splash = 'splash';
  static const String login = 'login';
  static const String home = 'home';
  static const String attendance = 'attendance';
  static const String calendar = 'calendar';
  static const String assignments = 'assignments';
  static const String profile = 'profile';
  static const String timetable = 'timetable';
  static const String internalMarks = 'internal-marks';
  static const String semester = 'semester';
  static const String settings = 'settings';
}

/// Navigator keys for each bottom navigation branch.
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _attendanceNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'attendance',
);
final _calendarNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'calendar');
final _assignmentsNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'assignments',
);
final _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

/// Creates the application's [GoRouter] instance.
///
/// Uses a [StatefulShellRoute] to maintain state across bottom navigation tabs.
/// The [ref] parameter is required for authentication redirect logic.
/// The [refreshListenable] triggers redirect re-evaluation when auth
/// state changes.
GoRouter createRouter(WidgetRef ref, {required Listenable refreshListenable}) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: false,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final currentPath = state.matchedLocation;

      // While auth is initializing, keep user on splash.
      if (authState is AuthInitial || authState is AuthLoading) {
        if (currentPath != RoutePaths.splash) return RoutePaths.splash;
        return null;
      }

      final isAuthenticated = authState is AuthAuthenticated;

      // Auth resolved: redirect away from splash.
      if (currentPath == RoutePaths.splash) {
        return isAuthenticated ? RoutePaths.home : RoutePaths.login;
      }

      // Authenticated user on login page → send to home.
      if (isAuthenticated && currentPath == RoutePaths.login) {
        return RoutePaths.home;
      }

      // Unauthenticated user on protected route → send to login.
      if (!isAuthenticated && !RoutePaths.publicRoutes.contains(currentPath)) {
        return RoutePaths.login;
      }

      return null;
    },
    routes: [
      // ── Splash ───────────────────────────────────────────────────────────
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // ── Login (outside shell) ──────────────────────────────────────────
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // ── Main shell with bottom navigation ──────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Home
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.home,
                name: RouteNames.home,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),

          // Attendance
          StatefulShellBranch(
            navigatorKey: _attendanceNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.attendance,
                name: RouteNames.attendance,
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Attendance'),
              ),
            ],
          ),

          // Calendar
          StatefulShellBranch(
            navigatorKey: _calendarNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.calendar,
                name: RouteNames.calendar,
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Calendar'),
              ),
            ],
          ),

          // Assignments
          StatefulShellBranch(
            navigatorKey: _assignmentsNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.assignments,
                name: RouteNames.assignments,
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Assignments'),
              ),
            ],
          ),

          // Profile
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                name: RouteNames.profile,
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Profile'),
              ),
            ],
          ),
        ],
      ),

      // ── Feature routes outside bottom nav ──────────────────────────────
      GoRoute(
        path: RoutePaths.timetable,
        name: RouteNames.timetable,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Timetable'),
      ),
      GoRoute(
        path: RoutePaths.internalMarks,
        name: RouteNames.internalMarks,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Internal Marks'),
      ),
      GoRoute(
        path: RoutePaths.semester,
        name: RouteNames.semester,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Semester Management'),
      ),
      GoRoute(
        path: RoutePaths.settings,
        name: RouteNames.settings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PlaceholderScreen(title: 'Settings'),
      ),
    ],
  );
}
