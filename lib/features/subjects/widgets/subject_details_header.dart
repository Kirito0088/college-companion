import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/theme/color_tokens.dart';
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
                      color: ColorTokens.onSurface,
                      fontWeight: FontWeight.bold,
                      letterSpacing: TypographyTokens.headlineLetterSpacing,
                    ),
                  ),
                  if (subject.faculty != null &&
                      subject.faculty!.trim().isNotEmpty) ...[
                    const SizedBox(height: SpacingTokens.xs),
                    Row(
                      children: [
                        const Icon(
                          Symbols.person,
                          size: IconSizeTokens.sm,
                          color: ColorTokens.primary,
                        ),
                        const SizedBox(width: SpacingTokens.xs),
                        Expanded(
                          child: Text(
                            subject.faculty!,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: ColorTokens.onSurfaceVariant,
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
                color: ColorTokens.primaryContainer.withValues(alpha: 0.6),
                borderRadius: RadiusTokens.borderRadiusSm,
                border: Border.all(
                  color: ColorTokens.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                subjectType,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: ColorTokens.onPrimaryContainer,
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
