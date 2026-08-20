import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/assignments/providers/assignments_provider.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/shared/widgets/dialogs/cc_dialogs.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

class AssignmentDetailsScreen extends ConsumerStatefulWidget {
  const AssignmentDetailsScreen({super.key, required this.assignmentId});

  final String assignmentId;

  @override
  ConsumerState<AssignmentDetailsScreen> createState() =>
      _AssignmentDetailsScreenState();
}

class _AssignmentDetailsScreenState
    extends ConsumerState<AssignmentDetailsScreen> {
  String get _userId {
    final auth = ref.read(authStateProvider);
    return (auth as AuthAuthenticated).user.uid;
  }

  Future<void> _markComplete() async {
    await ref
        .read(assignmentRepositoryProvider)
        .markCompleted(_userId, widget.assignmentId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Assignment marked as complete'),
          backgroundColor: ColorTokens.success,
        ),
      );
    }
  }

  Future<void> _deleteAssignment() async {
    final confirm = await CCDialogs.showDeleteConfirmation(
      context,
      title: 'Delete Assignment',
      message:
          'Are you sure you want to delete this assignment? This action cannot be undone.',
    );
    if (confirm == true && mounted) {
      await ref
          .read(assignmentRepositoryProvider)
          .delete(_userId, widget.assignmentId);
      if (mounted) context.pop();
    }
  }

  Future<void> _showEditSheet(AssignmentEntity assignment) async {
    final titleCtrl = TextEditingController(text: assignment.title);
    final descCtrl = TextEditingController(text: assignment.description ?? '');
    final theme = Theme.of(context);

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          margin: EdgeInsets.only(
            left: SpacingTokens.md,
            right: SpacingTokens.md,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + SpacingTokens.md,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: SpacingTokens.lg),
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ColorTokens.surfaceVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.xl),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.xl,
                ),
                child: Text(
                  'Edit Assignment',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ColorTokens.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.lg),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.xl,
                ),
                child: TextField(
                  controller: titleCtrl,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: ColorTokens.onSurface,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(color: ColorTokens.onSurfaceVariant),
                    filled: true,
                    fillColor: ColorTokens.surfaceContainerHigh,
                    border: OutlineInputBorder(
                      borderRadius: RadiusTokens.borderRadiusLg,
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: RadiusTokens.borderRadiusLg,
                      borderSide: BorderSide(
                        color: ColorTokens.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.xl,
                ),
                child: TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: ColorTokens.onSurface,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: ColorTokens.onSurfaceVariant),
                    filled: true,
                    fillColor: ColorTokens.surfaceContainerHigh,
                    border: OutlineInputBorder(
                      borderRadius: RadiusTokens.borderRadiusLg,
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: RadiusTokens.borderRadiusLg,
                      borderSide: BorderSide(
                        color: ColorTokens.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.xl),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.xl,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: SpacingTokens.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: ColorTokens.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: SpacingTokens.md),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: ColorTokens.primary,
                          foregroundColor: ColorTokens.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            vertical: SpacingTokens.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SpacingTokens.xl),
            ],
          ),
        );
      },
    );

    if (result == true && mounted) {
      await ref
          .read(assignmentRepositoryProvider)
          .update(
            _userId,
            widget.assignmentId,
            AssignmentsCompanion(
              title: Value(titleCtrl.text.trim()),
              description: Value(
                descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
              ),
              updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
            ),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Assignment updated'),
            backgroundColor: ColorTokens.primary,
          ),
        );
      }
    }
    titleCtrl.dispose();
    descCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repo = ref.watch(assignmentRepositoryProvider);

    return StreamBuilder<AssignmentEntity?>(
      stream: repo.watchById(_userId, widget.assignmentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: theme.colorScheme.surface,
            appBar: _buildAppBar(theme),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final assignment = snapshot.data;
        if (assignment == null) {
          return Scaffold(
            backgroundColor: theme.colorScheme.surface,
            appBar: _buildAppBar(theme),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Symbols.assignment_late,
                    size: 64,
                    color: ColorTokens.onSurfaceVariant,
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  Text(
                    'Assignment not found',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: ColorTokens.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final isCompleted = assignment.status == 'completed';
        final statusColor = isCompleted
            ? ColorTokens.success
            : ColorTokens.warning;
        final statusLabel = isCompleted ? 'Completed' : 'Pending';

        // Parse dates
        String dueDateStr = 'No due date';
        try {
          final d = DateTime.parse(assignment.dueDate);
          dueDateStr = DateFormat('EEEE, MMMM d, yyyy').format(d);
        } catch (_) {
          dueDateStr = assignment.dueDate;
        }
        String createdStr = '';
        try {
          final d = DateTime.parse(assignment.createdAt);
          createdStr = DateFormat('MMM d, yyyy').format(d);
        } catch (_) {}

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: _buildAppBar(theme),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: LayoutTokens.screenPadding,
                vertical: SpacingTokens.base,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    assignment.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ColorTokens.onSurface,
                    ),
                  ),
                  if (assignment.subjectId.isNotEmpty) ...[
                    const SizedBox(height: SpacingTokens.xs),
                    Text(
                      assignment.subjectId,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: ColorTokens.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: SpacingTokens.md),
                  Row(children: [_buildChip(theme, statusLabel, statusColor)]),

                  // Description
                  if (assignment.description != null &&
                      assignment.description!.isNotEmpty) ...[
                    const SizedBox(height: SpacingTokens.xl),
                    Text(
                      'Description',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ColorTokens.onSurface,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.sm),
                    Text(
                      assignment.description!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: ColorTokens.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],

                  // Dates
                  const SizedBox(height: SpacingTokens.xl),
                  Text(
                    'Timeline',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ColorTokens.onSurface,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  Container(
                    padding: const EdgeInsets.all(SpacingTokens.lg),
                    decoration: BoxDecoration(
                      color: ColorTokens.surfaceContainerHigh,
                      borderRadius: RadiusTokens.borderRadiusXl,
                      border: Border.all(
                        color: ColorTokens.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        if (createdStr.isNotEmpty)
                          _buildDateRow(
                            theme,
                            'Created',
                            createdStr,
                            Symbols.calendar_add_on,
                          ),
                        if (createdStr.isNotEmpty)
                          const Divider(
                            height: SpacingTokens.xl,
                            color: ColorTokens.surfaceVariant,
                          ),
                        _buildDateRow(
                          theme,
                          'Due',
                          dueDateStr,
                          Symbols.event_upcoming,
                        ),
                        if (isCompleted && assignment.completedAt != null) ...[
                          const Divider(
                            height: SpacingTokens.xl,
                            color: ColorTokens.surfaceVariant,
                          ),
                          _buildDateRow(theme, 'Completed', () {
                            try {
                              return DateFormat(
                                'MMM d, yyyy',
                              ).format(DateTime.parse(assignment.completedAt!));
                            } catch (_) {
                              return assignment.completedAt!;
                            }
                          }(), Symbols.task_alt),
                        ],
                      ],
                    ),
                  ),

                  // Additional Notes
                  if (assignment.description != null &&
                      assignment.description!.isNotEmpty) ...[
                    const SizedBox(height: SpacingTokens.xl),
                    Text(
                      'Notes',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ColorTokens.onSurface,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.sm),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(SpacingTokens.lg),
                      decoration: BoxDecoration(
                        color: ColorTokens.surfaceContainerHigh,
                        borderRadius: RadiusTokens.borderRadiusXl,
                        border: Border.all(
                          color: ColorTokens.outlineVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                      child: Text(
                        assignment.description!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: ColorTokens.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],

                  // Actions
                  const SizedBox(height: SpacingTokens.xxl),
                  if (!isCompleted)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _markComplete,
                        icon: const Icon(Symbols.check_circle, size: 20),
                        label: const Text(
                          'Mark as Complete',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: SpacingTokens.lg,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: ColorTokens.success,
                          foregroundColor: ColorTokens.onPrimary,
                          elevation: 0,
                        ),
                      ),
                    ),
                  if (!isCompleted) const SizedBox(height: SpacingTokens.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showEditSheet(assignment),
                          icon: const Icon(Symbols.edit, size: 18),
                          label: const Text(
                            'Edit',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: SpacingTokens.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(
                              color: ColorTokens.outlineVariant,
                            ),
                            foregroundColor: ColorTokens.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: SpacingTokens.md),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _deleteAssignment,
                          icon: const Icon(Symbols.delete, size: 18),
                          label: const Text(
                            'Delete',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: SpacingTokens.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: ColorTokens.error.withValues(alpha: 0.5),
                            ),
                            foregroundColor: ColorTokens.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpacingTokens.xxl),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Symbols.arrow_back, color: ColorTokens.onSurface),
        onPressed: () => context.pop(),
      ),
      title: const Text('Assignment Details'),
    );
  }

  Widget _buildChip(ThemeData theme, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: RadiusTokens.borderRadiusMd,
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDateRow(
    ThemeData theme,
    String label,
    String date,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: ColorTokens.onSurfaceVariant),
        const SizedBox(width: SpacingTokens.md),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: ColorTokens.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          date,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: ColorTokens.onSurface,
          ),
        ),
      ],
    );
  }
}
