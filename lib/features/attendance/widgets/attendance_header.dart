import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class AttendanceHeader extends StatelessWidget {
  const AttendanceHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LayoutTokens.screenPadding,
      ),
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(SpacingTokens.sm),
                  child: Icon(
                    Symbols.arrow_back_rounded,
                    color: cc.mut,
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Text(
                'Attendance',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cc.fg,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.lg,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: cc.surf,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: cc.line),
              ),
              child: Row(
                children: [
                  Text(
                    'SEM 5',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: cc.mut,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  Icon(Symbols.expand_more_rounded, color: cc.mut, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
