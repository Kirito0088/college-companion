/// Timetable Screen
///
/// Dedicated weekly class schedule screen with day selector (Mon–Sun),
/// active lecture highlighting, and add/edit lecture management.
library;

import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/timetable/models/lecture_schedule_item.dart';
import 'package:college_companion/features/timetable/providers/timetable_provider.dart';
import 'package:college_companion/features/timetable/widgets/add_edit_timetable_entry_dialog.dart';
import 'package:college_companion/features/timetable/widgets/day_selector_segmented_button.dart';
import 'package:college_companion/features/timetable/widgets/lecture_card.dart';
import 'package:college_companion/shared/widgets/cc_empty_state.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Dedicated Timetable Screen for viewing and managing weekly class schedules.
class TimetableScreen extends ConsumerWidget {
  /// Creates a [TimetableScreen].
  const TimetableScreen({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    LectureScheduleItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Class Slot'),
        content: Text(
          'Remove ${item.subjectName} from ${item.dayName}\'s timetable?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: ColorTokens.error,
              foregroundColor: ColorTokens.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final authState = ref.read(authStateProvider);
      final userId = authState is AuthAuthenticated ? authState.user.uid : '';
      if (userId.isNotEmpty) {
        final repo = ref.read(timetableRepositoryProvider);
        await repo.delete(userId, item.id);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Class slot deleted')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedDay = ref.watch(selectedDayProvider);
    final lecturesAsync = ref.watch(timetableForDayProvider(selectedDay));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Timetable'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Symbols.today),
            tooltip: 'Jump to Today',
            onPressed: () {
              final today = (DateTime.now().weekday - 1).clamp(0, 6);
              ref.read(selectedDayProvider.notifier).state = today;
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: LayoutTokens.screenPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: SpacingTokens.sm),

              // Day Selector (Mon - Sun)
              DaySelectorSegmentedButton(
                selectedDay: selectedDay,
                onDaySelected: (day) {
                  ref.read(selectedDayProvider.notifier).state = day;
                },
              ),
              const SizedBox(height: SpacingTokens.lg),

              // Schedule List
              Expanded(
                child: lecturesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Symbols.error_outline,
                          size: 40,
                          color: ColorTokens.error,
                        ),
                        const SizedBox(height: SpacingTokens.sm),
                        Text(
                          'Failed to load timetable',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: ColorTokens.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  data: (lectures) {
                    if (lectures.isEmpty) {
                      return Center(
                        child: CcEmptyState(
                          icon: Symbols.event_busy,
                          title: 'No classes scheduled',
                          subtitle: 'Enjoy your free day',
                          actionLabel: 'Add Class',
                          onAction: () => AddEditTimetableEntryDialog.show(
                            context,
                            initialDay: selectedDay,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.only(
                        bottom: SpacingTokens.massive,
                      ),
                      itemCount: lectures.length,
                      separatorBuilder: (_, index) =>
                          const SizedBox(height: SpacingTokens.md),
                      itemBuilder: (context, index) {
                        final item = lectures[index];
                        return LectureCard(
                          lecture: item,
                          onEdit: () => AddEditTimetableEntryDialog.show(
                            context,
                            initialItem: item,
                            initialDay: selectedDay,
                          ),
                          onDelete: () => _confirmDelete(context, ref, item),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: ColorTokens.primary,
        foregroundColor: ColorTokens.onPrimary,
        icon: const Icon(Symbols.add),
        label: const Text(
          'Add Class',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () =>
            AddEditTimetableEntryDialog.show(context, initialDay: selectedDay),
      ),
    );
  }
}
