import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class AssignmentsFab extends StatelessWidget {
  const AssignmentsFab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        left: LayoutTokens.screenPadding,
        right: LayoutTokens.screenPadding,
        top: SpacingTokens.xl,
        bottom: SpacingTokens.xl,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surface.withValues(alpha: 0.9),
            theme.colorScheme.surface.withValues(alpha: 0.0),
          ],
        ),
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorTokens.primary,
          foregroundColor: ColorTokens.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          elevation: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Symbols.add),
            const SizedBox(width: SpacingTokens.sm),
            Text(
              'New Assignment',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: ColorTokens.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
