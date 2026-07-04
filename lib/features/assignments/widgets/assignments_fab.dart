import 'package:college_companion/theme/color_tokens.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class AssignmentsFab extends StatelessWidget {
  const AssignmentsFab({super.key, this.isExtended = true});

  final bool isExtended;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 48,
      child: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: ColorTokens.primary,
        foregroundColor: ColorTokens.onPrimary,
        elevation: 1, // Reduced elevation
        isExtended: isExtended,
        extendedPadding: const EdgeInsets.symmetric(
          horizontal: 12,
        ), // Reduced padding
        icon: const Icon(Symbols.add, size: 18), // Smaller icon
        label: Text(
          'New Assignment',
          style: theme.textTheme.labelMedium?.copyWith(
            // Smaller label
            fontWeight: FontWeight.w500, // Reduced weight
            color: ColorTokens.onPrimary,
          ),
        ),
      ),
    );
  }
}
