import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class ProfileAppBar extends StatelessWidget {
  const ProfileAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: LayoutTokens.screenPadding, // px-screen-edge
        vertical: SpacingTokens.md, // py-4
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Profile',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: ColorTokens.onSurface,
              ),
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          IconButton(
            onPressed: () {}, // TODO: Navigate to settings
            icon: const Icon(Symbols.settings),
            color: ColorTokens.onSurfaceVariant,
            style: IconButton.styleFrom(
              hoverColor: ColorTokens.surfaceContainerHigh,
            ),
          ),
        ],
      ),
    );
  }
}
