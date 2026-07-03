import 'package:college_companion/features/semester/widgets/current_score_card.dart';
import 'package:college_companion/features/semester/widgets/marks_table_card.dart';
import 'package:college_companion/features/semester/widgets/semester_app_bar.dart';
import 'package:college_companion/features/semester/widgets/subject_header_card.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

class SemesterDetailsScreen extends StatelessWidget {
  const SemesterDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: SemesterAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: LayoutTokens.screenPadding,
          right: LayoutTokens.screenPadding,
          top: SpacingTokens.md,
          bottom: SpacingTokens.xxl * 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SubjectHeaderCard(),
            SizedBox(height: SpacingTokens.xl),
            MarksTableCard(),
            SizedBox(height: SpacingTokens.md),
            CurrentScoreCard(),
          ],
        ),
      ),
    );
  }
}
