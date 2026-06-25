/// App Router Configuration
///
/// GoRouter with shell route for bottom navigation.
/// Tab order per 05-navigation.md: Home, Attendance, Calendar, Assignments, Profile.
/// Maximum navigation depth: 3 levels.
library;

import 'package:college_companion/routing/scaffold_with_nav_bar.dart';
import 'package:college_companion/shared/widgets/placeholder_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Route path constants.
abstract final class RoutePaths {
  // ── Root tabs ──────────────────────────────────────────────────────────
  static const String home = '/';
  static const String attendance = '/attendance';
  static const String calendar = '/calendar';
  static const String assignments = '/assignments';
  static const String profile = '/profile';

  // ── Secondary routes ───────────────────────────────────────────────────
  static const String login = '/login';
  static const String timetable = '/timetable';
  static const String internalMarks = '/internal-marks';
  static const String semester = '/semester';
  static const String settings = '/settings';
}

/// Route name constants for named navigation.
abstract final class RouteNames {
  static const String home = 'home';
  static const String attendance = 'attendance';
  static const String calendar = 'calendar';
  static const String assignments = 'assignments';
  static const String profile = 'profile';
  static const String login = 'login';
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
GoRouter createRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.home,
    debugLogDiagnostics: false,

    // TODO(auth): Add redirect logic for authentication state.
    // redirect: (context, state) {
    //   final isAuthenticated = ...;
    //   if (!isAuthenticated) return RoutePaths.login;
    //   return null;
    // },
    routes: [
      // ── Login (outside shell) ──────────────────────────────────────────
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const PlaceholderScreen(title: 'Login'),
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
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Dashboard'),
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
