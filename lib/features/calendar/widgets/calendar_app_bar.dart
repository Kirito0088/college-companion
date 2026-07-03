import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class CalendarAppBar extends StatelessWidget {
  const CalendarAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LayoutTokens.screenPadding,
        vertical: SpacingTokens.base, // py-4
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  }
                },
                icon: const Icon(Symbols.arrow_back),
                style: IconButton.styleFrom(
                  hoverColor: ColorTokens.surfaceContainerHigh,
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Text(
                'Calendar',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Symbols.event,
                  color: ColorTokens.onSurfaceVariant,
                ),
                style: IconButton.styleFrom(
                  hoverColor: ColorTokens.surfaceContainerHigh,
                ),
              ),
              const SizedBox(width: SpacingTokens.xs),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Symbols.more_vert,
                  color: ColorTokens.onSurfaceVariant,
                ),
                style: IconButton.styleFrom(
                  hoverColor: ColorTokens.surfaceContainerHigh,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
