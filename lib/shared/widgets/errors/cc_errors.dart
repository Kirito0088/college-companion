import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class NetworkErrorWidget extends StatelessWidget {
  const NetworkErrorWidget({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return _BaseError(
      icon: Icons.wifi_off,
      title: 'Network Error',
      message: 'Please check your internet connection and try again.',
      buttonLabel: onRetry != null ? 'Retry' : null,
      onAction: onRetry,
    );
  }
}

class UnknownErrorWidget extends StatelessWidget {
  const UnknownErrorWidget({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return _BaseError(
      icon: Icons.error_outline,
      title: 'Something went wrong',
      message: 'An unexpected error occurred. Please try again later.',
      buttonLabel: onRetry != null ? 'Retry' : null,
      onAction: onRetry,
    );
  }
}

class RetryStateWidget extends StatelessWidget {
  const RetryStateWidget({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _BaseError(
      icon: Icons.refresh,
      title: 'Failed to load',
      message: 'We couldn\'t load this content.',
      buttonLabel: 'Try Again',
      onAction: onRetry,
    );
  }
}

class OfflineStateWidget extends StatelessWidget {
  const OfflineStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const _BaseError(
      icon: Icons.cloud_off,
      title: 'You are offline',
      message: 'This feature is not available while offline.',
    );
  }
}

class _BaseError extends StatelessWidget {
  const _BaseError({
    required this.icon,
    required this.title,
    required this.message,
    this.buttonLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: SpacingTokens.lg),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonLabel != null && onAction != null) ...[
              const SizedBox(height: SpacingTokens.xl),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Symbols.refresh, size: 18),
                label: Text(buttonLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
