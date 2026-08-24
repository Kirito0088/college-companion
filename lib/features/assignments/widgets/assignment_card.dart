import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class AssignmentCard extends StatelessWidget {
  const AssignmentCard({
    required this.title,
    required this.subject,
    this.subjectColor,
    required this.dueDate,
    required this.status,
    required this.statusColor,
    this.priority,
    required this.onTap,
    super.key,
  });

  final String title;
  final String subject;
  final Color? subjectColor;
  final String dueDate;
  final String status;
  final Color statusColor;
  final String? priority;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;

    return InkWell(
      onTap: onTap,
      borderRadius: RadiusTokens.borderRadiusMd,
      splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
      highlightColor: theme.colorScheme.primary.withValues(alpha: 0.05),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(SpacingTokens.md), // Reduced from lg
        decoration: BoxDecoration(
          color: cc.raise,
          borderRadius: RadiusTokens.borderRadiusMd,
          border: Border.all(color: cc.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(
                color: cc.fg,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: SpacingTokens.xs), // Tighter spacing
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (subjectColor != null) ...[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: subjectColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                ],
                Flexible(
                  child: Text(
                    subject,
                    style: theme.textTheme.bodyMedium?.copyWith(color: cc.mut),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.md), // Reduced from xl
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: SpacingTokens.md,
                    runSpacing: SpacingTokens.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SpacingTokens.sm,
                          vertical: SpacingTokens.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: RadiusTokens.borderRadiusSm,
                        ),
                        child: Text(
                          status,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Symbols.event,
                            size: 14, // Reduced from 16
                            color: cc.mut,
                          ),
                          const SizedBox(width: SpacingTokens.xs),
                          Text(
                            dueDate,
                            style: theme.textTheme.labelSmall?.copyWith(
                              // Reduced from labelMedium
                              color: cc.mut,
                            ),
                          ),
                        ],
                      ),
                      if (priority != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Symbols.flag,
                              size: 14, // Reduced from 16
                              color: cc.risk,
                            ),
                            const SizedBox(width: SpacingTokens.xs),
                            Text(
                              priority!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                // Reduced from labelMedium
                                color: cc.risk,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: SpacingTokens.sm), // Reduced from md
                Icon(
                  Symbols.chevron_right,
                  size: 20, // Reduced from 24
                  color: cc.mut,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
