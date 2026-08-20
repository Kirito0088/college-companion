import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/calendar/providers/calendar_provider.dart';
import 'package:college_companion/shared/widgets/dialogs/cc_dialogs.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

class EventDetailsScreen extends ConsumerWidget {
  const EventDetailsScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.read(authStateProvider);
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: Text('Not authenticated')));
    }
    final userId = authState.user.uid;
    final repo = ref.watch(calendarRepositoryProvider);

    return StreamBuilder(
      stream: repo.watchById(userId, eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: theme.colorScheme.surface,
            appBar: AppBar(
              backgroundColor: theme.colorScheme.surface,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(Symbols.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final event = snapshot.data;
        if (event == null) {
          return Scaffold(
            backgroundColor: theme.colorScheme.surface,
            appBar: AppBar(
              backgroundColor: theme.colorScheme.surface,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(Symbols.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Symbols.event_busy,
                    size: 64,
                    color: ColorTokens.onSurfaceVariant,
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  Text(
                    'Event not found',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: ColorTokens.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Parse dates
        DateTime? startDate;
        DateTime? endDate;
        try {
          startDate = DateTime.parse(event.startDate);
        } catch (_) {}
        try {
          if (event.endDate.isNotEmpty) endDate = DateTime.parse(event.endDate);
        } catch (_) {}

        final dateStr = startDate != null
            ? DateFormat('EEEE, MMMM d, yyyy').format(startDate)
            : 'No date';
        final timeStr = startDate != null
            ? '${DateFormat.jm().format(startDate)}${endDate != null ? ' – ${DateFormat.jm().format(endDate)}' : ''}'
            : 'No time';

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            backgroundColor: theme.colorScheme.surface,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Symbols.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(LayoutTokens.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    event.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ColorTokens.onSurface,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  Row(
                    children: [
                      if (event.eventType.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: SpacingTokens.sm,
                            vertical: SpacingTokens.xs,
                          ),
                          decoration: BoxDecoration(
                            color: _eventTypeColor(
                              event.eventType,
                            ).withValues(alpha: 0.1),
                            borderRadius: RadiusTokens.borderRadiusSm,
                          ),
                          child: Text(
                            _capitalizeFirst(event.eventType),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: _eventTypeColor(event.eventType),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: SpacingTokens.xl),
                  _buildInfoCard(
                    theme: theme,
                    children: [
                      _buildInfoRow(
                        theme: theme,
                        icon: Symbols.calendar_today,
                        label: 'Date',
                        value: dateStr,
                      ),
                      const Divider(
                        height: SpacingTokens.lg,
                        color: ColorTokens.surfaceVariant,
                      ),
                      _buildInfoRow(
                        theme: theme,
                        icon: Symbols.schedule,
                        label: 'Time',
                        value: timeStr,
                      ),
                    ],
                  ),
                  if (event.description != null &&
                      event.description!.isNotEmpty) ...[
                    const SizedBox(height: SpacingTokens.lg),
                    _buildInfoCard(
                      theme: theme,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Symbols.notes,
                              size: 20,
                              color: ColorTokens.onSurfaceVariant,
                            ),
                            const SizedBox(width: SpacingTokens.md),
                            Text(
                              'Description',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: ColorTokens.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: SpacingTokens.sm),
                        Text(
                          event.description!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: ColorTokens.onSurface,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: SpacingTokens.xxl),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final confirm = await CCDialogs.showDeleteConfirmation(
                        context,
                        title: 'Delete Event',
                        message:
                            'Are you sure you want to delete "${event.title}"? This action cannot be undone.',
                      );
                      if (confirm == true && context.mounted) {
                        await repo.delete(userId, eventId);
                        if (context.mounted) context.pop();
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ColorTokens.error,
                      side: const BorderSide(color: ColorTokens.error),
                      padding: const EdgeInsets.symmetric(
                        vertical: SpacingTokens.md,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: RadiusTokens.borderRadiusMd,
                      ),
                    ),
                    icon: const Icon(Symbols.delete, size: 18),
                    label: const Text('Delete Event'),
                  ),
                  const SizedBox(height: SpacingTokens.xl),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _eventTypeColor(String type) {
    return switch (type.toLowerCase()) {
      'exam' => ColorTokens.error,
      'assignment' => ColorTokens.warning,
      'holiday' => ColorTokens.success,
      'lecture' => ColorTokens.primary,
      _ => ColorTokens.tertiary,
    };
  }

  String _capitalizeFirst(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  Widget _buildInfoCard({
    required ThemeData theme,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        color: ColorTokens.surfaceContainer,
        borderRadius: RadiusTokens.borderRadiusLg,
        border: Border.all(color: ColorTokens.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInfoRow({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: ColorTokens.onSurfaceVariant),
        const SizedBox(width: SpacingTokens.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: ColorTokens.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: SpacingTokens.xxs),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: ColorTokens.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
