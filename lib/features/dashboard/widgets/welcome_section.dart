/// Welcome Section Widget
///
/// Displays a personalized greeting to the user.
/// Uses [authStateProvider] to access user display name.
library;

import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A welcome card displaying the user's greeting.
///
/// Uses Riverpod to access the current authentication state
/// and extract the user's display name for personalization.
class WelcomeSection extends ConsumerWidget {
  /// Creates a [WelcomeSection].
  const WelcomeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Extract display name from authenticated state
    final displayName = authState is AuthAuthenticated
        ? extractDisplayName(authState.user.displayName)
        : 'Student';

    final greeting = getGreeting();

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.xl),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: RadiusTokens.borderRadiusMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: SpacingTokens.xxs),
          Text(
            displayName,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Formats the display name for display purposes.
  ///
  /// Converts "Firstname Lastname" to "Firstname" for greeting.
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
