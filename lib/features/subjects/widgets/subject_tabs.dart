import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

class SubjectTabs extends StatelessWidget {
  const SubjectTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ColorTokens.surfaceVariant, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTab(context, 'Overview', isActive: true),
            const SizedBox(width: SpacingTokens.xl), // gap-6
            _buildTab(context, 'Lectures', isActive: false),
            const SizedBox(width: SpacingTokens.xl),
            _buildTab(context, 'Attendance', isActive: false),
            const SizedBox(width: SpacingTokens.xl),
            _buildTab(context, 'Marks', isActive: false),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    String title, {
    required bool isActive,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.only(
        left: SpacingTokens.xs,
        right: SpacingTokens.xs,
        bottom: SpacingTokens.md, // pb-3
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isActive ? ColorTokens.primary : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: isActive ? ColorTokens.primary : ColorTokens.onSurfaceVariant,
        ),
      ),
    );
  }
}
