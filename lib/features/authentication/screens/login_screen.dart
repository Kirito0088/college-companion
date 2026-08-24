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
///
/// ADR-011: serif wordmark (Newsreader) and a small "day-spine" decorative
/// motif — a vertical timeline of dots — replace the plain icon logo.
library;

import 'package:college_companion/core/constants/app_constants.dart';
import 'package:college_companion/core/extensions/context_extensions.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:college_companion/theme/typography_tokens.dart';
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

              // ── Day-Spine Motif ──────────────────────────────────────
              const _DaySpine(),
              const SizedBox(height: SpacingTokens.xl),

              // ── App Name (serif wordmark) ─────────────────────────────
              Text(
                AppConstants.appName,
                style: TypographyTokens.serifTextTheme.headlineLarge?.copyWith(
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

/// A small decorative "day-spine" motif — a vertical timeline of dots
/// with a highlighted "today" node — echoing the dashboard's spine
/// timeline (ADR-011 canvas) as the login screen's wordmark accent.
class _DaySpine extends StatelessWidget {
  const _DaySpine();

  @override
  Widget build(BuildContext context) {
    final cc = context.cc;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SpineDot(color: cc.line2, size: 6),
        _SpineSegment(color: cc.line),
        _SpineDot(color: cc.line2, size: 6),
        _SpineSegment(color: cc.line),
        _TodayNode(cc: cc),
        _SpineSegment(color: cc.line),
        _SpineDot(color: cc.line2, size: 6),
      ],
    );
  }
}

class _SpineSegment extends StatelessWidget {
  const _SpineSegment({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(width: 1.5, height: SpacingTokens.md, color: color);
  }
}

class _SpineDot extends StatelessWidget {
  const _SpineDot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _TodayNode extends StatelessWidget {
  const _TodayNode({required this.cc});

  final CCTokens cc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        color: cc.pri,
        shape: BoxShape.circle,
        boxShadow: cc.shadow,
      ),
      child: Icon(
        Symbols.school_rounded,
        size: SpacingTokens.xl,
        color: cc.priFg,
      ),
    );
  }
}
