import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class SemesterAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SemesterAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: LayoutTokens.screenPadding,
          vertical: SpacingTokens.md,
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
              icon: const Icon(Symbols.arrow_back),
              color: cc.mut,
              iconSize: 24,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: SpacingTokens.md),
            Expanded(
              child: Text(
                'Internal Marks',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Plus Jakarta Sans',
                  color: cc.fg,
                ),
              ),
            ),
            Material(
              color: cc.raise,
              borderRadius: RadiusTokens.borderRadiusPill,
              child: InkWell(
                onTap: () {},
                borderRadius: RadiusTokens.borderRadiusPill,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'SEM 5',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: cc.mut,
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      Icon(Symbols.expand_more, size: 16, color: cc.mut),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64.0);
}
