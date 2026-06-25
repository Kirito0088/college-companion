/// Scaffold with Navigation Bar
///
/// Wraps the [StatefulNavigationShell] with a [NavigationBar] providing
/// the 5-tab bottom navigation per 05-navigation.md.
///
/// Tab order: Home, Attendance, Calendar, Assignments, Profile.
/// Navigation items always contain both icon and label (per 02-design-system.md).
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A scaffold that wraps [StatefulNavigationShell] with bottom navigation.
class ScaffoldWithNavBar extends StatelessWidget {
  /// Creates a [ScaffoldWithNavBar] with the given [navigationShell].
  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  /// The navigation shell provided by [StatefulShellRoute].
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Symbols.home_rounded),
            selectedIcon: Icon(Symbols.home_rounded, fill: 1),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Symbols.fact_check_rounded),
            selectedIcon: Icon(Symbols.fact_check_rounded, fill: 1),
            label: 'Attendance',
          ),
          NavigationDestination(
            icon: Icon(Symbols.calendar_month_rounded),
            selectedIcon: Icon(Symbols.calendar_month_rounded, fill: 1),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Symbols.assignment_rounded),
            selectedIcon: Icon(Symbols.assignment_rounded, fill: 1),
            label: 'Academics',
          ),
          NavigationDestination(
            icon: Icon(Symbols.person_rounded),
            selectedIcon: Icon(Symbols.person_rounded, fill: 1),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
