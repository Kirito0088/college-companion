import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class AttendanceHeader extends StatelessWidget {
  const AttendanceHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LayoutTokens.screenPadding,
      ),
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(SpacingTokens.sm),
                      child: Icon(
                        Symbols.arrow_back_rounded,
                        color: ColorTokens.onSurfaceVariant,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: SpacingTokens.sm),
                Text(
                  'Attendance',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ColorTokens.onSurface,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: ColorTokens.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: ColorTokens.outlineVariant),
              ),
              child: Row(
                children: [
                  Text(
                    'SEM 5',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: ColorTokens.onSurfaceVariant,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  const Icon(
                    Symbols.expand_more_rounded,
                    color: ColorTokens.onSurfaceVariant,
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
