import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class SafeBunkAppBar extends StatelessWidget {
  const SafeBunkAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: LayoutTokens.screenPadding, // px-screen-edge
        vertical: SpacingTokens.md, // py-4
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Symbols.arrow_back),
            color: cc.mut,
            style: IconButton.styleFrom(hoverColor: cc.raise2),
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Text(
              'Safe Bunk Calculator',
              style: theme.textTheme.headlineSmall?.copyWith(color: cc.fg),
            ),
          ),
          const SizedBox(
            width: 48,
          ), // Spacer for balance since no trailing icons
        ],
      ),
    );
  }
}
