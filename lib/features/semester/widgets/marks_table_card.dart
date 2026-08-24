import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

class MarksTableCard extends StatelessWidget {
  const MarksTableCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Internal Components',
          style: theme.textTheme.titleMedium?.copyWith(
            color: cc.mut,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: SpacingTokens.base),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border.all(color: cc.line),
            borderRadius: RadiusTokens.borderRadiusMd,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderRow(theme, cc),
              _buildRow(theme, cc, 'Test 1', '20', '18'),
              _buildRow(theme, cc, 'Test 2', '20', '16'),
              _buildRow(theme, cc, 'Assignment 1', '10', '9'),
              _buildRow(theme, cc, 'Assignment 2', '10', '8'),
              _buildRow(theme, cc, 'Mini Project', '20', '-', isLast: true),
              _buildFooterRow(theme, cc),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderRow(ThemeData theme, CCTokens cc) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cc.line)),
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
                color: cc.mut,
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
                color: cc.mut,
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
                color: cc.mut,
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
    CCTokens cc,
    String component,
    String max,
    String scored, {
    bool isLast = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: cc.line.withValues(alpha: 0.5))),
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
              style: theme.textTheme.bodyMedium?.copyWith(color: cc.fg),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              max,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(color: cc.mut),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              scored,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(color: cc.fg),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterRow(ThemeData theme, CCTokens cc) {
    return Container(
      decoration: BoxDecoration(color: cc.raise.withValues(alpha: 0.2)),
      padding: const EdgeInsets.symmetric(
        vertical: SpacingTokens.base,
        horizontal: SpacingTokens.base,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Total',
              style: theme.textTheme.titleMedium?.copyWith(color: cc.fg),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              '80',
              textAlign: TextAlign.right,
              style: theme.textTheme.titleMedium?.copyWith(color: cc.fg),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              '51',
              textAlign: TextAlign.right,
              style: theme.textTheme.titleMedium?.copyWith(color: cc.pri),
            ),
          ),
        ],
      ),
    );
  }
}
