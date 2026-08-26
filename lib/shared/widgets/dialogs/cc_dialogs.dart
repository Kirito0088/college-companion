/// Shared confirmation/feedback dialogs.
///
/// ADR-011 (issue #26): colors come from `Theme.of(context).colorScheme`
/// so every dialog follows the user's theme + accent selection. The legacy
/// static color constants in `lib/theme/` are dark/jade-only and must not
/// be referenced from here.
library;

import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

class CCDialogs {
  CCDialogs._();

  static Future<bool?> showLogoutConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        return AlertDialog(
          title: const Text('Log out'),
          content: const Text(
            'Are you sure you want to log out of your account?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  static Future<bool?> showDeleteConfirmation(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(SpacingTokens.md),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: SpacingTokens.lg),
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  // The opaque hairline, not a raised-surface fill — in the
                  // light theme `surface` and the first elevation step are
                  // both white, so a surface-toned handle would vanish.
                  color: colors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: SpacingTokens.xl),
              Container(
                padding: const EdgeInsets.all(SpacingTokens.lg),
                decoration: BoxDecoration(
                  color: colors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: colors.error,
                  size: 32,
                ),
              ),
              const SizedBox(height: SpacingTokens.lg),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.xl,
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.xl,
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.xxl),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.xl,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: SpacingTokens.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: SpacingTokens.md),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.error,
                          foregroundColor: colors.onError,
                          padding: const EdgeInsets.symmetric(
                            vertical: SpacingTokens.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height:
                    MediaQuery.of(context).padding.bottom + SpacingTokens.xl,
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<bool?> showDiscardChanges(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        return AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text(
            'You have unsaved changes. Are you sure you want to discard them?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Keep Editing'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Discard'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showSuccessDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: colors.primary),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(child: Text(title)),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: colors.error),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(child: Text(title)),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
