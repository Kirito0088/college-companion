import 'package:college_companion/shared/models/mock_ui_state.dart';
import 'package:college_companion/shared/widgets/empty_states/cc_empty_states.dart';
import 'package:college_companion/shared/widgets/errors/cc_errors.dart';
import 'package:college_companion/shared/widgets/loading/cc_skeletons.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  MockUiState _uiState = MockUiState.success;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back),
          color: ColorTokens.onSurface,
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Alerts & Activity',
          style: theme.textTheme.titleLarge?.copyWith(
            color: ColorTokens.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Symbols.done_all),
            color: ColorTokens.onSurfaceVariant,
            onPressed: () {}, // TODO: Mark all as read
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_uiState) {
      case MockUiState.loading:
        return ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: LayoutTokens.screenPadding,
            vertical: SpacingTokens.md,
          ),
          children: const [
            SkeletonNotification(),
            SizedBox(height: SpacingTokens.md),
            SkeletonNotification(),
            SizedBox(height: SpacingTokens.md),
            SkeletonNotification(),
          ],
        );
      case MockUiState.empty:
        return const EmptyNotifications();
      case MockUiState.error:
        return NetworkErrorWidget(
          onRetry: () {
            setState(() {
              _uiState = MockUiState.loading;
              Future.delayed(
                const Duration(seconds: 1),
                () => setState(() => _uiState = MockUiState.success),
              );
            });
          },
        );
      case MockUiState.success:
        return ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: LayoutTokens.screenPadding,
            vertical: SpacingTokens.md,
          ),
          children: const [
            _NotificationGroup(
              title: 'Critical Academic Alerts',
              notifications: [
                _NotificationItem(
                  icon: Symbols.warning,
                  iconColor: ColorTokens.error,
                  title: 'Attendance Below Threshold',
                  message:
                      'Your Operating Systems attendance has dropped to 72%. Attend the next 3 lectures to recover.',
                  time: 'Just now',
                  isUnread: true,
                ),
                _NotificationItem(
                  icon: Symbols.assignment_late,
                  iconColor: ColorTokens.warning,
                  title: 'Submission Overdue',
                  message:
                      'Software Engineering Phase 2 was due 4 hours ago. Submit immediately for partial credit.',
                  time: '4h ago',
                  isUnread: true,
                  showBorder: false,
                ),
              ],
            ),
            SizedBox(height: LayoutTokens.sectionGap),
            _NotificationGroup(
              title: 'Upcoming Today',
              notifications: [
                _NotificationItem(
                  icon: Symbols.event,
                  iconColor: ColorTokens.primary,
                  title: 'Exam Starts Tomorrow',
                  message:
                      'Mid-Sem: Database Management Systems is scheduled for tomorrow at 10:00 AM.',
                  time: '1h ago',
                  isUnread: true,
                ),
                _NotificationItem(
                  icon: Symbols.schedule,
                  iconColor: ColorTokens.secondary,
                  title: 'Next Lecture in 20 Mins',
                  message:
                      'Computer Networks (Lab) starts in 20 minutes in Room L-204.',
                  time: '2h ago',
                  isUnread: false,
                ),
                _NotificationItem(
                  icon: Symbols.campaign,
                  iconColor: ColorTokens.warning,
                  title: 'Room Changed',
                  message:
                      'Data Structures & Algorithms has been moved from Room 402 to Seminar Hall A.',
                  time: '3h ago',
                  isUnread: false,
                  showBorder: false,
                ),
              ],
            ),
            SizedBox(height: LayoutTokens.sectionGap),
            _NotificationGroup(
              title: 'Insights & Updates',
              notifications: [
                _NotificationItem(
                  icon: Symbols.fact_check,
                  iconColor: ColorTokens.success,
                  title: 'Marks Published',
                  message:
                      'Internal Assessment 1 marks for Mathematics IV have been uploaded.',
                  time: '1d ago',
                  isUnread: false,
                ),
                _NotificationItem(
                  icon: Symbols.psychology,
                  iconColor: ColorTokens.primary,
                  title: 'Today\'s Study Plan Ready',
                  message:
                      'Your AI Planner has scheduled 2 hours of review for DBMS before tomorrow\'s exam.',
                  time: '1d ago',
                  isUnread: false,
                ),
                _NotificationItem(
                  icon: Symbols.cloud_done,
                  iconColor: ColorTokens.onSurfaceVariant,
                  title: 'Offline Changes Synced',
                  message:
                      'All local attendance and timetable updates have been backed up securely.',
                  time: '1d ago',
                  isUnread: false,
                  showBorder: false,
                ),
              ],
            ),
          ],
        );
    }
  }
}

class _NotificationGroup extends StatelessWidget {
  const _NotificationGroup({required this.title, required this.notifications});

  final String title;
  final List<Widget> notifications;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: SpacingTokens.sm,
            bottom: SpacingTokens.sm,
          ),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: ColorTokens.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: ColorTokens.surfaceContainer,
            borderRadius: RadiusTokens.borderRadiusXl,
            border: Border.all(
              color: ColorTokens.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: notifications),
        ),
      ],
    );
  }
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.time,
    required this.isUnread,
    this.showBorder = true,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String time;
  final bool isUnread;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isUnread
          ? ColorTokens.primaryContainer.withValues(alpha: 0.3)
          : Colors.transparent,
      child: InkWell(
        onTap: () {},
        hoverColor: ColorTokens.surfaceContainerHigh,
        child: Container(
          padding: const EdgeInsets.all(LayoutTokens.cardPadding),
          decoration: BoxDecoration(
            border: showBorder
                ? Border(
                    bottom: BorderSide(
                      color: ColorTokens.outlineVariant.withValues(alpha: 0.3),
                    ),
                  )
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(SpacingTokens.sm),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: ColorTokens.onSurface,
                              fontWeight: isUnread
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(
                              left: SpacingTokens.sm,
                            ),
                            decoration: const BoxDecoration(
                              color: ColorTokens.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: SpacingTokens.xs),
                    Text(
                      message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isUnread
                            ? ColorTokens.onSurface
                            : ColorTokens.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.xs),
                    Text(
                      time,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ColorTokens.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
