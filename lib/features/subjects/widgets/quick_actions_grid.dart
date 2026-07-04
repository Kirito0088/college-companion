import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleMedium?.copyWith(
            color: ColorTokens.onSurface,
          ),
        ),
        const SizedBox(height: SpacingTokens.md), // mb-4
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Symbols.menu_book,
                iconColor: ColorTokens.secondary, // approx secondary-fixed
                label: 'View Lectures',
                onTap: () {},
              ),
            ),
            const SizedBox(width: SpacingTokens.md),
            Expanded(
              child: _QuickActionCard(
                icon: Symbols.sticky_note_2,
                iconColor: ColorTokens.warning,
                label: 'View Notes',
                onTap: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: SpacingTokens.md),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Symbols.description,
                iconColor: ColorTokens.tertiary,
                label: 'Internal Marks',
                onTap: () => context.push('/semester'),
              ),
            ),
            const SizedBox(width: SpacingTokens.md),
            Expanded(
              child: _QuickActionCard(
                icon: Symbols.folder,
                iconColor: ColorTokens.secondary,
                label: 'Resources',
                onTap: () => context.push('/resources'),
              ),
            ),
          ],
        ),
        const SizedBox(height: SpacingTokens.md),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Symbols.calendar_month,
                iconColor: ColorTokens.primary,
                label: 'Calendar (Test)',
                onTap: () => context.push('/calendar'),
              ),
            ),
            const SizedBox(width: SpacingTokens.md),
            const Spacer(),
          ],
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: RadiusTokens.borderRadiusMd,
      child: Container(
        padding: const EdgeInsets.all(SpacingTokens.md), // p-4
        decoration: BoxDecoration(
          color: ColorTokens.surfaceContainer,
          borderRadius: RadiusTokens.borderRadiusMd, // rounded-xl => 12px
          border: Border.all(color: ColorTokens.surfaceVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, // w-10
              height: 40, // h-10
              decoration: const BoxDecoration(
                color: ColorTokens.surfaceContainer,
                borderRadius: RadiusTokens.borderRadiusSm, // rounded-lg => 8px
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(height: SpacingTokens.sm), // gap-3 ~= 12px
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: ColorTokens.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
