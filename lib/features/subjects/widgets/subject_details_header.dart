import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/icon_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:college_companion/theme/typography_tokens.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Header displaying subject identity, faculty, and classification tags.
class SubjectDetailsHeader extends StatelessWidget {
  const SubjectDetailsHeader({super.key, required this.subject});

  final SubjectEntity subject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;
    final subjectType = subject.type.toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.name,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: cc.fg,
                      fontWeight: FontWeight.bold,
                      letterSpacing: TypographyTokens.headlineLetterSpacing,
                    ),
                  ),
                  if (subject.faculty != null &&
                      subject.faculty!.trim().isNotEmpty) ...[
                    const SizedBox(height: SpacingTokens.xs),
                    Row(
                      children: [
                        Icon(
                          Symbols.person,
                          size: IconSizeTokens.sm,
                          color: cc.pri,
                        ),
                        const SizedBox(width: SpacingTokens.xs),
                        Expanded(
                          child: Text(
                            subject.faculty!,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: cc.mut,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: SpacingTokens.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md,
                vertical: SpacingTokens.xs,
              ),
              decoration: BoxDecoration(
                color: cc.priSoft,
                borderRadius: RadiusTokens.borderRadiusSm,
                border: Border.all(color: cc.pri.withValues(alpha: 0.3)),
              ),
              child: Text(
                subjectType,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cc.pri,
                  fontWeight: FontWeight.bold,
                  letterSpacing: TypographyTokens.labelUppercaseSpacing,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
