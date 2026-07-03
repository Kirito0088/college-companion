import 'package:college_companion/features/calendar/widgets/calendar_app_bar.dart';
import 'package:college_companion/features/calendar/widgets/calendar_event_list.dart';
import 'package:college_companion/features/calendar/widgets/calendar_grid.dart';
import 'package:college_companion/features/calendar/widgets/calendar_month_selector.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: const SafeArea(
        child: Column(
          children: [
            CalendarAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: LayoutTokens.screenPadding,
                  right: LayoutTokens.screenPadding,
                  top: SpacingTokens.base, // pt-4
                  bottom: SpacingTokens.huge, // pb-20 equivalent
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CalendarMonthSelector(),
                    SizedBox(height: SpacingTokens.lg), // gap-6
                    CalendarGrid(),
                    SizedBox(height: SpacingTokens.xxl),
                    CalendarEventList(),
                    SizedBox(
                      height: SpacingTokens.huge,
                    ), // bottom spacing for FAB
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SafeArea(
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: ColorTokens.inversePrimary,
          foregroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Symbols.add),
        ),
      ),
    );
  }
}
