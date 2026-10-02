import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class AttendanceHeader extends StatelessWidget {
  const AttendanceHeader({super.key, this.semesterName});

  /// The current semester's name, or null to show no semester chip.
  final String? semesterName;

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
            // Was a literal 'SEM 5' with a dropdown chevron that opened
            // nothing (#38). Shows the real current semester, or nothing.
            if (semesterName case final name? when name.isNotEmpty) ...[
              const SizedBox(width: SpacingTokens.sm),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.lg,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: cc.surf,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: cc.line),
                  ),
                  child: Text(
                    name,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: cc.mut,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
