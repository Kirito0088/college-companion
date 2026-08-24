import 'package:college_companion/routing/scaffold_with_nav_bar.dart';
import 'package:college_companion/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('ScaffoldWithNavBar Widget Tests', () {
    testWidgets('Renders all 5 destinations with labels', (
      WidgetTester tester,
    ) async {
      final router = _buildRouter();

      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.darkTheme, routerConfig: router),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Attendance'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Assignments'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('Tapping a destination switches the active branch', (
      WidgetTester tester,
    ) async {
      final router = _buildRouter();

      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.darkTheme, routerConfig: router),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home Page'), findsOneWidget);

      await tester.tap(find.text('Attendance'));
      await tester.pumpAndSettle();

      expect(find.text('Attendance Page'), findsOneWidget);
    });
  });
}

GoRouter _buildRouter() {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldWithNavBar(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) =>
                    const Center(child: Text('Home Page')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/attendance',
                builder: (context, state) =>
                    const Center(child: Text('Attendance Page')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) =>
                    const Center(child: Text('Calendar Page')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/academics',
                builder: (context, state) =>
                    const Center(child: Text('Academics Page')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) =>
                    const Center(child: Text('Profile Page')),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
