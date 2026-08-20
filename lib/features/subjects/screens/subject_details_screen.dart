import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/subjects/providers/subject_detail_provider.dart';
import 'package:college_companion/features/subjects/widgets/mark_attendance_sheet.dart';
import 'package:college_companion/features/subjects/widgets/subject_attendance_filter_bar.dart';
import 'package:college_companion/features/subjects/widgets/subject_attendance_timeline.dart';
import 'package:college_companion/features/subjects/widgets/subject_details_header.dart';
import 'package:college_companion/features/subjects/widgets/subject_metric_overview.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/icon_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Dynamic Subject Details and Bunk Calculator Screen.
///
/// Features:
/// - Reactive attendance metrics and safe bunk calculations.
/// - Filterable attendance log timeline (All, Present, Absent, Cancelled).
/// - Quick attendance marking modal bottom sheet.
class SubjectDetailsScreen extends ConsumerWidget {
  const SubjectDetailsScreen({super.key, this.subjectId = ''});

  final String subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final userId =
        authState is AuthAuthenticated && authState.user.uid.isNotEmpty
        ? authState.user.uid
        : 'default_user';

    final params = (userId: userId, subjectId: subjectId);
    final stateAsync = ref.watch(subjectDetailProvider(params));
    final controller = ref.read(subjectDetailControllerProvider(params));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back, size: IconSizeTokens.md),
          color: ColorTokens.onSurface,
          onPressed: () => context.pop(),
        ),
        title: Text(
          stateAsync.valueOrNull?.subject?.name ?? 'Subject Details',
          style: theme.textTheme.titleMedium?.copyWith(
            color: ColorTokens.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('mark_attendance_fab'),
        onPressed: () {
          MarkAttendanceSheet.show(
            context,
            onSave:
                ({
                  required String status,
                  required DateTime date,
                  required String lectureType,
                  String? notes,
                }) async {
                  await controller.markAttendance(
                    status: status,
                    date: date,
                    lectureType: lectureType,
                    notes: notes,
                  );
                },
          );
        },
        backgroundColor: ColorTokens.primary,
        foregroundColor: ColorTokens.onPrimary,
        icon: const Icon(Symbols.add, size: IconSizeTokens.md),
        label: const Text('Mark Attendance'),
        shape: const RoundedRectangleBorder(
          borderRadius: RadiusTokens.borderRadiusPill,
        ),
      ),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.xl),
            child: Text(
              'Error loading subject: $error',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ColorTokens.error,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: LayoutTokens.screenPadding,
              right: LayoutTokens.screenPadding,
              top: SpacingTokens.md,
              bottom: LayoutTokens.bottomNavigationHeight + SpacingTokens.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Subject Header
                if (state.subject != null)
                  SubjectDetailsHeader(subject: state.subject!)
                else
                  SubjectDetailsHeader(
                    subject: SubjectEntity(
                      id: subjectId,
                      userId: userId,
                      semesterId: '',
                      name: 'Subject',
                      type: 'theory',
                      createdAt: '',
                      updatedAt: '',
                    ),
                  ),
                const SizedBox(height: LayoutTokens.sectionGap),

                // Bunk Calculator & Metrics Overview
                SubjectMetricOverview(
                  bunkMetrics: state.bunkMetrics,
                  presentCount: state.presentCount,
                  absentCount: state.absentCount,
                  cancelledCount: state.cancelledCount,
                ),
                const SizedBox(height: LayoutTokens.sectionGap),

                // Attendance History Header & Filter Chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Attendance History',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: ColorTokens.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SpacingTokens.sm),
                SubjectAttendanceFilterBar(
                  selectedFilter: state.selectedFilter,
                  onFilterSelected: (filter) {
                    ref
                            .read(attendanceFilterProvider(subjectId).notifier)
                            .state =
                        filter;
                  },
                  totalCount: state.allRecords.length,
                  presentCount: state.presentCount,
                  absentCount: state.absentCount,
                  cancelledCount: state.cancelledCount,
                ),
                const SizedBox(height: SpacingTokens.md),

                // Filtered Timeline of Attendance Sessions
                SubjectAttendanceTimeline(
                  records: state.filteredRecords,
                  onEdit: (record) {
                    MarkAttendanceSheet.show(
                      context,
                      initialStatus: record.primaryStatus,
                      initialLectureType: record.lectureType,
                      initialNotes: record.notes,
                      initialDate: DateTime.tryParse(record.date),
                      onSave:
                          ({
                            required String status,
                            required DateTime date,
                            required String lectureType,
                            String? notes,
                          }) async {
                            await controller.updateAttendance(
                              id: record.id,
                              status: status,
                              notes: notes,
                            );
                          },
                    );
                  },
                  onDelete: (record) async {
                    await controller.deleteAttendance(record.id);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
