import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class SubjectAppBar extends StatelessWidget {
  const SubjectAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: LayoutTokens.screenPadding,
        vertical: SpacingTokens.md,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Symbols.arrow_back),
            color: ColorTokens.onSurface,
            style: IconButton.styleFrom(
              hoverColor: ColorTokens.surfaceContainerHigh,
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Text(
              'Subject Overview',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: ColorTokens.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 40), // Spacer for balance
        ],
      ),
    );
  }
}
