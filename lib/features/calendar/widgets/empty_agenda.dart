import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class EmptyAgenda extends StatelessWidget {
  const EmptyAgenda({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: ColorTokens.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Symbols.event_upcoming,
                  size: 32,
                  color: ColorTokens.primary,
                ),
              ),
              const SizedBox(height: SpacingTokens.lg),
              Text(
                'Nothing scheduled today.',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: ColorTokens.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SpacingTokens.xxs),
              Text(
                'Enjoy your free day, or add a new event.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: ColorTokens.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
