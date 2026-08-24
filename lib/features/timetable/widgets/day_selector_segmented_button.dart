/// Day Selector Segmented Button
///
/// Segmented button / tabs widget for switching between days of the week (Monday=0 to Sunday=6).
library;

import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

/// A segmented day selector displaying Monday through Sunday tabs.
class DaySelectorSegmentedButton extends StatelessWidget {
  /// Creates a [DaySelectorSegmentedButton].
  const DaySelectorSegmentedButton({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
  });

  /// The currently active day index (0 = Monday, ..., 6 = Sunday).
  final int selectedDay;

  /// Callback when a day tab is tapped.
  final ValueChanged<int> onDaySelected;

  static const List<String> _dayLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;

    return Container(
      height: 48,
      padding: const EdgeInsets.all(SpacingTokens.xs),
      decoration: BoxDecoration(
        color: cc.raise,
        borderRadius: RadiusTokens.borderRadiusPill,
        border: Border.all(color: cc.line, width: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: List.generate(_dayLabels.length, (index) {
              final isSelected = selectedDay == index;
              return Expanded(
                child: Semantics(
                  button: true,
                  selected: isSelected,
                  label: _dayLabels[index],
                  child: InkWell(
                    key: Key('day_selector_tab_$index'),
                    onTap: () => onDaySelected(index),
                    borderRadius: RadiusTokens.borderRadiusPill,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? cc.pri : Colors.transparent,
                        borderRadius: RadiusTokens.borderRadiusPill,
                      ),
                      child: Text(
                        _dayLabels[index],
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: isSelected ? cc.priFg : cc.mut,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
