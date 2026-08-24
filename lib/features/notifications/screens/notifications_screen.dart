import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/notifications/providers/notification_provider.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cc = context.cc;
    final authState = ref.watch(authStateProvider);
    final userId = authState is AuthAuthenticated ? authState.user.uid : null;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Alerts & Activity')),
        body: const Center(child: Text('Not authenticated')),
      );
    }

    final notificationsAsync = ref.watch(notificationsStreamProvider(userId));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back),
          color: cc.fg,
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Alerts & Activity',
          style: theme.textTheme.titleLarge?.copyWith(
            color: cc.fg,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Symbols.done_all),
            color: cc.mut,
            tooltip: 'Mark all as read',
            onPressed: () {
              ref.read(notificationRepositoryProvider).markAllRead(userId);
            },
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Text(
                'No notifications right now.',
                style: TextStyle(color: cc.mut),
              ),
            );
          }

          final today = <NotificationEntity>[];
          final yesterday = <NotificationEntity>[];
          final earlier = <NotificationEntity>[];

          final now = DateTime.now();
          final startOfToday = DateTime(now.year, now.month, now.day);
          final startOfYesterday = startOfToday.subtract(
            const Duration(days: 1),
          );

          for (final n in notifications) {
            final date = DateTime.parse(n.createdAt).toLocal();
            if (date.isAfter(startOfToday) ||
                date.isAtSameMomentAs(startOfToday)) {
              today.add(n);
            } else if (date.isAfter(startOfYesterday) ||
                date.isAtSameMomentAs(startOfYesterday)) {
              yesterday.add(n);
            } else {
              earlier.add(n);
            }
          }

          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: LayoutTokens.screenPadding,
              vertical: SpacingTokens.md,
            ),
            children: [
              if (today.isNotEmpty) ...[
                _NotificationGroup(
                  title: 'Today',
                  notifications: today.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return _NotificationItem(
                      notification: item,
                      userId: userId,
                      showBorder: index != today.length - 1,
                    );
                  }).toList(),
                ),
                if (yesterday.isNotEmpty || earlier.isNotEmpty)
                  const SizedBox(height: LayoutTokens.sectionGap),
              ],
              if (yesterday.isNotEmpty) ...[
                _NotificationGroup(
                  title: 'Yesterday',
                  notifications: yesterday.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return _NotificationItem(
                      notification: item,
                      userId: userId,
                      showBorder: index != yesterday.length - 1,
                    );
                  }).toList(),
                ),
                if (earlier.isNotEmpty)
                  const SizedBox(height: LayoutTokens.sectionGap),
              ],
              if (earlier.isNotEmpty)
                _NotificationGroup(
                  title: 'Earlier',
                  notifications: earlier.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return _NotificationItem(
                      notification: item,
                      userId: userId,
                      showBorder: index != earlier.length - 1,
                    );
                  }).toList(),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error loading notifications: $error',
            style: TextStyle(color: cc.risk),
          ),
        ),
      ),
    );
  }
}

class _NotificationGroup extends StatelessWidget {
  const _NotificationGroup({required this.title, required this.notifications});

  final String title;
  final List<Widget> notifications;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;
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
              color: cc.mut,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cc.raise,
            borderRadius: RadiusTokens.borderRadiusXl,
            border: Border.all(color: cc.line.withValues(alpha: 0.2)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: notifications),
        ),
      ],
    );
  }
}

class _NotificationItem extends ConsumerWidget {
  const _NotificationItem({
    required this.notification,
    required this.userId,
    this.showBorder = true,
  });

  final NotificationEntity notification;
  final String userId;
  final bool showBorder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cc = context.cc;

    IconData icon;
    Color iconColor;

    switch (notification.type) {
      case 'academic_alert':
        icon = Symbols.warning;
        iconColor = cc.risk;
        break;
      case 'insight':
        icon = Symbols.psychology;
        iconColor = cc.pri;
        break;
      case 'upcoming':
        icon = Symbols.event;
        iconColor = cc.pri;
        break;
      default:
        icon = Symbols.notifications;
        iconColor = theme.colorScheme.secondary;
    }

    final date = DateTime.parse(notification.createdAt).toLocal();
    final timeStr = timeago.format(date, allowFromNow: true);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: cc.risk,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: SpacingTokens.xl),
        child: Icon(Symbols.delete, color: cc.priFg),
      ),
      onDismissed: (direction) {
        ref
            .read(notificationRepositoryProvider)
            .delete(userId, notification.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Notification deleted')));
      },
      child: Material(
        color: !notification.isRead
            ? cc.priSoft.withValues(alpha: 0.3)
            : Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!notification.isRead) {
              ref
                  .read(notificationRepositoryProvider)
                  .markRead(userId, notification.id);
            }
            if (notification.targetRoute != null &&
                notification.targetRoute!.isNotEmpty) {
              context.push(notification.targetRoute!);
            }
          },
          hoverColor: cc.raise2,
          child: Container(
            padding: const EdgeInsets.all(LayoutTokens.cardPadding),
            decoration: BoxDecoration(
              border: showBorder
                  ? Border(
                      bottom: BorderSide(color: cc.line.withValues(alpha: 0.3)),
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
                              notification.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: cc.fg,
                                fontWeight: !notification.isRead
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(
                                left: SpacingTokens.sm,
                              ),
                              decoration: BoxDecoration(
                                color: cc.pri,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: SpacingTokens.xs),
                      Text(
                        notification.message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: !notification.isRead ? cc.fg : cc.mut,
                        ),
                      ),
                      const SizedBox(height: SpacingTokens.xs),
                      Text(
                        timeStr,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cc.mut,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
