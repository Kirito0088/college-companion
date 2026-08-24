import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class CalendarAppBar extends StatelessWidget {
  const CalendarAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;

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
                style: IconButton.styleFrom(hoverColor: cc.raise2),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Text(
                'Calendar',
                style: theme.textTheme.titleLarge?.copyWith(color: cc.fg),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(Symbols.event, color: cc.mut),
                style: IconButton.styleFrom(hoverColor: cc.raise2),
              ),
              const SizedBox(width: SpacingTokens.xs),
              IconButton(
                onPressed: () {},
                icon: Icon(Symbols.more_vert, color: cc.mut),
                style: IconButton.styleFrom(hoverColor: cc.raise2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
