/// Welcome Section Widget
///
/// Displays a personalized greeting to the user with a notification bell.
/// Uses [authStateProvider] to access the user's display name.
library;

import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A welcome header displaying the greeting, user name, and a notification bell.
class WelcomeSection extends ConsumerWidget {
  /// Creates a [WelcomeSection].
  const WelcomeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Extract display name from authenticated state.
    final displayName = authState is AuthAuthenticated
        ? extractDisplayName(authState.user.displayName)
        : 'Student';

    final greeting = getGreeting();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            '$greeting,\n$displayName 👋',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ),
        Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorTokens.surfaceVariant,
            border: Border.all(color: ColorTokens.surfaceVariant),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {},
            icon: Icon(
              Symbols.notifications_rounded,
              color: colorScheme.onSurface,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  /// Formats the display name for display purposes.
  static String extractDisplayName(String fullName) {
    final parts = fullName.trim().split(' ');
    return parts.first;
  }

  /// Returns an appropriate greeting based on current time of day.
  static String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}
