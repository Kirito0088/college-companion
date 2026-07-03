import 'package:college_companion/shared/widgets/cc_card.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.name,
    required this.email,
    required this.semester,
    required this.course,
  });

  final String name;
  final String email;
  final String semester;
  final String course;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return CCCard(
      padding: const EdgeInsets.all(LayoutTokens.cardPadding),
      child: Row(
        children: [
          Container(
            width: 64, // w-16
            height: 64, // h-16
            decoration: const BoxDecoration(
              color: ColorTokens.primaryContainer,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: ColorTokens.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: SpacingTokens.base), // gap-4
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: ColorTokens.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: ColorTokens.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: SpacingTokens.sm), // mt-2 approx
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10, // px-2.5
                    vertical: SpacingTokens.xs, // py-1
                  ),
                  decoration: BoxDecoration(
                    color: ColorTokens.surfaceVariant,
                    borderRadius: RadiusTokens.borderRadiusPill,
                    border: Border.all(color: ColorTokens.outlineVariant),
                  ),
                  child: Text(
                    '$semester • $course',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: ColorTokens.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
