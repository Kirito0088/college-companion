import 'package:college_companion/theme/color_tokens.dart';
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
              color: ColorTokens.onSurfaceVariant,
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
                  color: ColorTokens.onSurface,
                ),
              ),
            ),
            Material(
              color: ColorTokens.surfaceVariant,
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
                          color: ColorTokens.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      const Icon(
                        Symbols.expand_more,
                        size: 16,
                        color: ColorTokens.onSurfaceVariant,
                      ),
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
