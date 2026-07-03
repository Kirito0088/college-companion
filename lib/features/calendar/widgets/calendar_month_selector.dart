import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class CalendarMonthSelector extends StatelessWidget {
  const CalendarMonthSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Symbols.chevron_left,
              color: ColorTokens.onSurface,
            ),
            style: IconButton.styleFrom(hoverColor: ColorTokens.surfaceVariant),
          ),
          Text(
            'May 2025',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Symbols.chevron_right,
              color: ColorTokens.onSurface,
            ),
            style: IconButton.styleFrom(hoverColor: ColorTokens.surfaceVariant),
          ),
        ],
      ),
    );
  }
}
