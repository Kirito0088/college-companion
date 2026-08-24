import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class AssignmentsAppBar extends StatelessWidget {
  const AssignmentsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LayoutTokens.screenPadding,
        vertical: SpacingTokens.base,
      ),
      child: Row(
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
            'Assignments',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
