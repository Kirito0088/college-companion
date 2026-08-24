import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class SubjectHeaderCard extends StatelessWidget {
  const SubjectHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.base),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: cc.line),
        borderRadius: RadiusTokens.borderRadiusMd,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cc.raise,
              borderRadius: RadiusTokens.borderRadiusSm,
            ),
            alignment: Alignment.center,
            child: Icon(Symbols.neurology, color: cc.pri, fill: 1.0, size: 24),
          ),
          const SizedBox(width: SpacingTokens.base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Artificial Intelligence',
                  style: theme.textTheme.titleMedium?.copyWith(color: cc.fg),
                ),
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  'Prof. Sharma',
                  style: theme.textTheme.bodyMedium?.copyWith(color: cc.mut),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
