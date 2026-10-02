import 'package:college_companion/shared/widgets/cc_card.dart';
import 'package:college_companion/theme/cc_tokens.dart';
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

  /// The semester number as the student entered it (e.g. `5`), or empty.
  final String semester;

  /// The student's course/branch, or empty.
  final String course;

  String? get _pillLabel {
    final parts = [
      if (semester.isNotEmpty) 'SEM $semester',
      if (course.isNotEmpty) course,
    ];
    return parts.isEmpty ? null : parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return CCCard(
      padding: const EdgeInsets.all(LayoutTokens.cardPadding),
      child: Row(
        children: [
          Container(
            width: 64, // w-16
            height: 64, // h-16
            decoration: BoxDecoration(
              color: cc.priSoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: cc.pri,
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
                  style: theme.textTheme.titleLarge?.copyWith(color: cc.fg),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  email,
                  style: theme.textTheme.bodyMedium?.copyWith(color: cc.mut),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: SpacingTokens.sm), // mt-2 approx
                // Only the parts the student has filled in; an empty
                // profile used to render "SEM •" (#38).
                if (_pillLabel case final label?)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12, // slightly increased for pill shape
                      vertical: 6, // better breathing room
                    ),
                    decoration: BoxDecoration(
                      color: cc.raise2,
                      borderRadius: RadiusTokens.borderRadiusPill,
                      border: Border.all(color: cc.line),
                    ),
                    child: Text(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: cc.mut,
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
