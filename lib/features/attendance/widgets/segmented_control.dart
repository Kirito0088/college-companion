import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

class SegmentedControl extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cc.raise,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cc.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSegment(
              context,
              theme: theme,
              cc: cc,
              index: 0,
              label: 'Overview',
            ),
          ),
          Expanded(
            child: _buildSegment(
              context,
              theme: theme,
              cc: cc,
              index: 1,
              label: 'Subjects',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegment(
    BuildContext context, {
    required ThemeData theme,
    required CCTokens cc,
    required int index,
    required String label,
  }) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onChanged(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
        decoration: isSelected
            ? BoxDecoration(
                color: cc.pri,
                borderRadius: BorderRadius.circular(6),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              )
            : null,
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: isSelected ? cc.priFg : cc.mut.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
