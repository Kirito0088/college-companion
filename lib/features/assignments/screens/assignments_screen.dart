import 'package:college_companion/features/assignments/widgets/assignment_card.dart';
import 'package:college_companion/features/assignments/widgets/assignments_app_bar.dart';
import 'package:college_companion/features/assignments/widgets/assignments_fab.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: DefaultTabController(
          length: 3,
          child: Stack(
            children: [
              Column(
                children: [
                  const AssignmentsAppBar(),
                  TabBar(
                    labelColor: ColorTokens.primary,
                    labelStyle: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelColor: ColorTokens.onSurfaceVariant,
                    unselectedLabelStyle: theme.textTheme.titleMedium,
                    indicatorColor: ColorTokens.primary,
                    indicatorWeight: 2,
                    dividerColor: ColorTokens.surfaceVariant,
                    padding: const EdgeInsets.symmetric(
                      horizontal: LayoutTokens.screenPadding,
                    ),
                    tabs: const [
                      Tab(text: 'Pending'),
                      Tab(text: 'Submitted'),
                      Tab(text: 'Completed'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [_buildList(), _buildList(), _buildList()],
                    ),
                  ),
                ],
              ),
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AssignmentsFab(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.only(
        left: LayoutTokens.screenPadding,
        right: LayoutTokens.screenPadding,
        top: SpacingTokens.base,
        bottom: 120, // Space for FAB
      ),
      itemCount: 4,
      separatorBuilder: (context, index) =>
          const SizedBox(height: SpacingTokens.lg),
      itemBuilder: (context, index) {
        return const AssignmentCard(
          title: 'AI Mini Project Report',
          subject: 'Artificial Intelligence',
          dueDate: 'Tomorrow, 11:59 PM',
          timeLeft: '1 Day Left',
        );
      },
    );
  }
}
