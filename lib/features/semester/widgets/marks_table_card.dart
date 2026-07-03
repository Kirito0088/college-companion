import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

class MarksTableCard extends StatelessWidget {
  const MarksTableCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Internal Components',
          style: theme.textTheme.titleMedium?.copyWith(
            color: ColorTokens.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: SpacingTokens.base),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border.all(color: ColorTokens.surfaceVariant),
            borderRadius: RadiusTokens.borderRadiusMd,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderRow(theme),
              _buildRow(theme, 'Test 1', '20', '18'),
              _buildRow(theme, 'Test 2', '20', '16'),
              _buildRow(theme, 'Assignment 1', '10', '9'),
              _buildRow(theme, 'Assignment 2', '10', '8'),
              _buildRow(theme, 'Mini Project', '20', '-', isLast: true),
              _buildFooterRow(theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderRow(ThemeData theme) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ColorTokens.surfaceVariant)),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 12.0,
        horizontal: SpacingTokens.base,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Component',
              style: theme.textTheme.labelLarge?.copyWith(
                color: ColorTokens.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              'Max',
              textAlign: TextAlign.right,
              style: theme.textTheme.labelLarge?.copyWith(
                color: ColorTokens.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              'Scored',
              textAlign: TextAlign.right,
              style: theme.textTheme.labelLarge?.copyWith(
                color: ColorTokens.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    ThemeData theme,
    String component,
    String max,
    String scored, {
    bool isLast = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: ColorTokens.surfaceVariant.withValues(alpha: 0.5),
                ),
              ),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 12.0,
        horizontal: SpacingTokens.base,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              component,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ColorTokens.onSurface,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              max,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ColorTokens.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              scored,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ColorTokens.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterRow(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: ColorTokens.surfaceVariant.withValues(alpha: 0.2),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: SpacingTokens.base,
        horizontal: SpacingTokens.base,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Total',
              style: theme.textTheme.titleMedium?.copyWith(
                color: ColorTokens.onSurface,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              '80',
              textAlign: TextAlign.right,
              style: theme.textTheme.titleMedium?.copyWith(
                color: ColorTokens.onSurface,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              '51',
              textAlign: TextAlign.right,
              style: theme.textTheme.titleMedium?.copyWith(
                color: ColorTokens.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
