import 'package:college_companion/theme/color_tokens.dart';
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

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ColorTokens.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ColorTokens.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(0),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
                decoration: selectedIndex == 0
                    ? BoxDecoration(
                        color: ColorTokens.primary,
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
                    'Overview',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: selectedIndex == 0
                          ? ColorTokens.onPrimary
                          : ColorTokens.onSurfaceVariant.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(1),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
                decoration: selectedIndex == 1
                    ? BoxDecoration(
                        color: ColorTokens.primary,
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
                    'Subjects',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: selectedIndex == 1
                          ? ColorTokens.onPrimary
                          : ColorTokens.onSurfaceVariant.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
