import 'package:college_companion/features/subjects/widgets/quick_actions_grid.dart';
import 'package:college_companion/features/subjects/widgets/subject_app_bar.dart';
import 'package:college_companion/features/subjects/widgets/subject_attendance_stats.dart';
import 'package:college_companion/features/subjects/widgets/subject_identity_card.dart';
import 'package:college_companion/features/subjects/widgets/subject_tabs.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

class SubjectOverviewScreen extends StatelessWidget {
  const SubjectOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: const SafeArea(
        child: Column(
          children: [
            SubjectAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: LayoutTokens.screenPadding,
                  right: LayoutTokens.screenPadding,
                  top: SpacingTokens.xs,
                  bottom:
                      LayoutTokens.bottomNavigationHeight + SpacingTokens.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SubjectIdentityCard(),
                    SizedBox(height: LayoutTokens.sectionGap),
                    SubjectTabs(),
                    SizedBox(height: LayoutTokens.sectionGap),
                    SubjectAttendanceStats(),
                    SizedBox(height: LayoutTokens.sectionGap),
                    QuickActionsGrid(),
                    SizedBox(height: SpacingTokens.sm),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
