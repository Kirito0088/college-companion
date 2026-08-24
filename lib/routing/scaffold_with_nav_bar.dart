/// Scaffold with Navigation Bar
///
/// Wraps the [StatefulNavigationShell] with the 5-tab bottom navigation
/// per 05-navigation.md.
///
/// This is a hand-rolled bottom bar rather than Material's [NavigationBar]:
/// [NavigationDestination]'s label is a bare `String` rendered internally
/// with no `maxLines`/`overflow` (see the Flutter SDK's
/// `navigation_bar.dart`), so there is no supported way to stop a label
/// from wrapping mid-word once its destination's share of the bar gets
/// narrow — exactly the failure this widget exists to fix (issue #32).
/// Rebuilding the 5 items directly restores that control while keeping the
/// same pill-indicator / filled-icon-on-select visual language.
///
/// Tab order: Home, Attendance, Calendar, Assignments, Profile.
/// Navigation items always contain both icon and label (per 02-design-system.md).
library;

import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class _NavDestination {
  const _NavDestination({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

const _destinations = [
  _NavDestination(icon: Symbols.home_rounded, label: 'Home'),
  _NavDestination(icon: Symbols.fact_check_rounded, label: 'Attendance'),
  _NavDestination(icon: Symbols.calendar_month_rounded, label: 'Calendar'),
  _NavDestination(icon: Symbols.assignment_rounded, label: 'Assignments'),
  _NavDestination(icon: Symbols.person_rounded, label: 'Profile'),
];

/// A scaffold that wraps [StatefulNavigationShell] with bottom navigation.
class ScaffoldWithNavBar extends StatelessWidget {
  /// Creates a [ScaffoldWithNavBar] with the given [navigationShell].
  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  /// The navigation shell provided by [StatefulShellRoute].
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final cc = context.cc;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(color: cc.raise),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 80,
            child: Row(
              children: [
                for (var i = 0; i < _destinations.length; i++)
                  Expanded(
                    child: _NavBarItem(
                      destination: _destinations[i],
                      selected: navigationShell.currentIndex == i,
                      onTap: () => navigationShell.goBranch(
                        i,
                        initialLocation: i == navigationShell.currentIndex,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _NavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cc = context.cc;
    final colorScheme = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: selected ? colorScheme.primary : cc.mut,
      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      letterSpacing: 0,
    );

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.lg,
                  vertical: SpacingTokens.xxs,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? colorScheme.primary.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: RadiusTokens.borderRadiusPill,
                ),
                child: Icon(
                  destination.icon,
                  size: 24,
                  fill: selected ? 1 : 0,
                  color: selected ? colorScheme.primary : cc.mut,
                ),
              ),
              const SizedBox(height: SpacingTokens.xxs),
              Text(
                destination.label,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: labelStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
