import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

class EventTypeChip extends StatelessWidget {
  const EventTypeChip({
    super.key,
    required this.label,
    required this.color,
    this.isSelected = false,
    this.onSelected,
  });

  final String label;
  final Color color;
  final bool isSelected;
  final ValueChanged<bool>? onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedTheme(
      data: theme.copyWith(canvasColor: Colors.transparent),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: onSelected,
        backgroundColor: ColorTokens.surfaceContainer,
        selectedColor: color.withValues(alpha: 0.15),
        labelStyle: theme.textTheme.labelMedium?.copyWith(
          color: isSelected ? color : ColorTokens.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
        side: BorderSide(
          color: isSelected ? Colors.transparent : ColorTokens.outlineVariant,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: RadiusTokens.borderRadiusMd,
        ),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.sm,
          vertical: SpacingTokens.xs,
        ),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
