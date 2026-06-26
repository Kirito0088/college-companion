/// Splash Screen
///
/// Per 08-screen-specifications.md:
/// - Displays branding while authentication initializes.
/// - Navigation is handled by the router redirect — not by this widget.
library;

import 'package:college_companion/core/constants/app_constants.dart';
import 'package:college_companion/core/extensions/context_extensions.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// The splash screen displayed on app launch.
///
/// Shows app branding and a loading indicator while the authentication
/// provider initializes. All navigation decisions are centralized
/// in the GoRouter redirect — this widget has no navigation logic.
class SplashScreen extends StatelessWidget {
  /// Creates a [SplashScreen].
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Symbols.school_rounded,
              size: SpacingTokens.massive,
              color: context.colorScheme.primary,
            ),
            const SizedBox(height: SpacingTokens.base),
            Text(
              AppConstants.appName,
              style: context.textTheme.headlineMedium?.copyWith(
                color: context.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: SpacingTokens.xxl),
            SizedBox(
              width: SpacingTokens.xl,
              height: SpacingTokens.xl,
              child: CircularProgressIndicator(
                strokeWidth: SpacingTokens.xxs,
                color: context.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
