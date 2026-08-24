import 'package:college_companion/features/assignments/widgets/add_assignment_dialog.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class AssignmentsFab extends StatelessWidget {
  const AssignmentsFab({super.key, this.isExtended = true});

  final bool isExtended;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;

    return SizedBox(
      height: 48,
      child: FloatingActionButton.extended(
        onPressed: () => AddAssignmentDialog.show(context),
        backgroundColor: cc.pri,
        foregroundColor: cc.priFg,
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
            color: cc.priFg,
          ),
        ),
      ),
    );
  }
}
