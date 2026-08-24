import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

class ProfileAppBar extends StatelessWidget {
  const ProfileAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;

    return Container(
      color: cc.bg,
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
              style: theme.textTheme.headlineSmall?.copyWith(color: cc.fg),
            ),
          ),
        ],
      ),
    );
  }
}
