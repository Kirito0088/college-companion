/// Login Screen
///
/// Per 08-screen-specifications.md:
/// - App Logo
/// - App Name
/// - Continue with Google Button
/// - Privacy Note
///
/// No email/password. No sign-up form. Google Sign-In only.
///
/// Navigation after successful sign-in is handled by the GoRouter
/// redirect — this widget only triggers the sign-in action
/// and displays error feedback.
library;

import 'package:college_companion/core/constants/app_constants.dart';
import 'package:college_companion/core/extensions/context_extensions.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

/// The login screen for Google Sign-In authentication.
///
/// Navigation decisions are centralized in the GoRouter redirect.
/// This widget only handles user interaction (sign-in button)
/// and UI feedback (error snackbar).
class LoginScreen extends ConsumerWidget {
  /// Creates a [LoginScreen].
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState is AuthLoading;

    // Show error feedback. Navigation is handled by the router.
    ref.listen(authStateProvider, (_, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.message)));
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: LayoutTokens.screenPadding,
          ),
          child: Column(
            children: [
              const Spacer(flex: 3),

              // ── App Logo ─────────────────────────────────────────────
              Icon(
                Symbols.school_rounded,
                size: 80,
                color: context.colorScheme.primary,
              ),
              const SizedBox(height: SpacingTokens.xl),

              // ── App Name ─────────────────────────────────────────────
              Text(
                AppConstants.appName,
                style: context.textTheme.headlineLarge?.copyWith(
                  color: context.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SpacingTokens.sm),

              // ── App Description ──────────────────────────────────────
              Text(
                AppConstants.appDescription,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),

              // ── Google Sign-In Button ────────────────────────────────
              _GoogleSignInButton(
                isLoading: isLoading,
                onPressed: isLoading
                    ? null
                    : () => ref.read(authStateProvider.notifier).signIn(),
              ),

              const SizedBox(height: SpacingTokens.xl),

              // ── Privacy Note ─────────────────────────────────────────
              Text(
                'By continuing, you agree to our Terms of Service '
                'and Privacy Policy.',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: SpacingTokens.huge),
            ],
          ),
        ),
      ),
    );
  }
}

/// Google Sign-In button with loading state support.
class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilledButton(
      onPressed: onPressed,
      child: isLoading
          ? SizedBox(
              height: SpacingTokens.xl,
              width: SpacingTokens.xl,
              child: CircularProgressIndicator(
                strokeWidth: SpacingTokens.xxs,
                color: theme.colorScheme.onPrimary,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Symbols.login_rounded,
                  size: SpacingTokens.lg,
                  color: theme.colorScheme.onPrimary,
                ),
                const SizedBox(width: SpacingTokens.sm),
                const Text('Continue with Google'),
              ],
            ),
    );
  }
}
