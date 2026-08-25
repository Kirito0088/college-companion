import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/semester/providers/semester_provider.dart';
import 'package:college_companion/features/subjects/providers/subjects_provider.dart';
import 'package:college_companion/shared/widgets/dialogs/cc_dialogs.dart';
import 'package:college_companion/shared/widgets/empty_states/cc_empty_states.dart';
import 'package:college_companion/shared/widgets/errors/cc_error_state.dart';
import 'package:college_companion/shared/widgets/loading/cc_skeletons.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:uuid/uuid.dart';

class SemesterDetailsScreen extends ConsumerStatefulWidget {
  const SemesterDetailsScreen({super.key, required this.semesterId});

  final String semesterId;

  @override
  ConsumerState<SemesterDetailsScreen> createState() =>
      _SemesterDetailsScreenState();
}

class _SemesterDetailsScreenState extends ConsumerState<SemesterDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;
    final authState = ref.watch(authStateProvider);
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: Text('Not authenticated')));
    }
    final userId = authState.user.uid;

    final semesterAsync = ref.watch(
      semesterByIdStreamProvider((
        userId: userId,
        semesterId: widget.semesterId,
      )),
    );
    final subjectsAsync = ref.watch(
      subjectsBySemesterStreamProvider((
        userId: userId,
        semesterId: widget.semesterId,
      )),
    );

    return semesterAsync.when(
      data: (semester) {
        if (semester == null) {
          return Scaffold(
            backgroundColor: theme.colorScheme.surface,
            appBar: _buildAppBar(theme, cc, 'Semester'),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Symbols.school, size: 64, color: cc.mut),
                  const SizedBox(height: SpacingTokens.md),
                  Text(
                    'Semester not found',
                    style: theme.textTheme.titleMedium?.copyWith(color: cc.mut),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: _buildAppBar(theme, cc, semester.name),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: LayoutTokens.screenPadding,
              vertical: SpacingTokens.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(theme, cc, semester),
                const SizedBox(height: LayoutTokens.sectionGap),
                _buildOverviewCard(theme, cc, semester, subjectsAsync),
                const SizedBox(height: LayoutTokens.sectionGap),
                _buildSubjectsSection(theme, cc, userId, subjectsAsync),
                const SizedBox(height: LayoutTokens.sectionGap),
                _buildSemesterTimeline(theme, cc, semester),
                const SizedBox(height: LayoutTokens.sectionGap),
                _buildActionsSection(theme, cc, semester, userId),
                const SizedBox(height: SpacingTokens.xxl),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: _buildAppBar(theme, cc, 'Loading...'),
        body: const Padding(
          padding: EdgeInsets.all(LayoutTokens.screenPadding),
          child: SkeletonList(),
        ),
      ),
      error: (err, stack) => Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: _buildAppBar(theme, cc, 'Error'),
        body: Center(
          child: CcErrorState(
            error: err,
            onRetry: () => ref.invalidate(
              semesterByIdStreamProvider((
                userId: userId,
                semesterId: widget.semesterId,
              )),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(ThemeData theme, CCTokens cc, String title) {
    return AppBar(
      backgroundColor: theme.colorScheme.surface,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Symbols.arrow_back),
        color: cc.fg,
        onPressed: () => context.pop(),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          color: cc.fg,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeader(ThemeData theme, CCTokens cc, SemesterEntity semester) {
    final createdDate = DateTime.tryParse(semester.createdAt);
    final dateStr = createdDate != null
        ? DateFormat('MMMM yyyy').format(createdDate)
        : 'Unknown';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                semester.isCurrent ? 'Current Semester' : 'Semester',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: cc.fg,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: SpacingTokens.xs),
              Text(
                'Created $dateStr',
                style: theme.textTheme.bodyMedium?.copyWith(color: cc.mut),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md,
            vertical: SpacingTokens.xs,
          ),
          decoration: BoxDecoration(
            color: semester.isCurrent
                ? cc.priSoft.withValues(alpha: 0.5)
                : cc.raise2,
            borderRadius: RadiusTokens.borderRadiusSm,
          ),
          child: Text(
            semester.isCurrent
                ? 'ACTIVE'
                : (semester.isArchived ? 'ARCHIVED' : 'INACTIVE'),
            style: theme.textTheme.labelSmall?.copyWith(
              color: semester.isCurrent ? cc.pri : cc.mut,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(
    ThemeData theme,
    CCTokens cc,
    SemesterEntity semester,
    AsyncValue<List<SubjectEntity>> subjectsAsync,
  ) {
    final subjectCount = subjectsAsync.valueOrNull?.length ?? 0;

    return Container(
      padding: const EdgeInsets.all(LayoutTokens.cardPadding),
      decoration: BoxDecoration(
        color: cc.raise,
        borderRadius: RadiusTokens.borderRadiusXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: theme.textTheme.titleMedium?.copyWith(
              color: cc.fg,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          Row(
            children: [
              Expanded(
                child: _buildOverviewStat(
                  theme,
                  cc,
                  '$subjectCount',
                  'Subjects',
                ),
              ),
              Expanded(
                child: _buildOverviewStat(
                  theme,
                  cc,
                  semester.isCurrent
                      ? 'Active'
                      : (semester.isArchived ? 'Archived' : 'Inactive'),
                  'Status',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStat(
    ThemeData theme,
    CCTokens cc,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: cc.fg,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: cc.mut),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSubjectsSection(
    ThemeData theme,
    CCTokens cc,
    String userId,
    AsyncValue<List<SubjectEntity>> subjectsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: SpacingTokens.sm,
            bottom: SpacingTokens.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subjects',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: cc.fg,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showAddSubjectDialog(context, userId),
                icon: const Icon(Symbols.add, size: 18),
                label: const Text('Add'),
                style: TextButton.styleFrom(
                  foregroundColor: cc.pri,
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.sm,
                  ),
                ),
              ),
            ],
          ),
        ),
        subjectsAsync.when(
          data: (subjects) {
            if (subjects.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(LayoutTokens.cardPadding * 2),
                decoration: BoxDecoration(
                  color: cc.raise,
                  borderRadius: RadiusTokens.borderRadiusXl,
                ),
                child: Column(
                  children: [
                    Icon(
                      Symbols.menu_book,
                      size: 48,
                      color: cc.mut.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    Text(
                      'No subjects yet',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: cc.mut,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.sm),
                    Text(
                      'Add subjects to start tracking this semester',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cc.mut.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: SpacingTokens.lg),
                    FilledButton.icon(
                      onPressed: () => _showAddSubjectDialog(context, userId),
                      icon: const Icon(Symbols.add, size: 18),
                      label: const Text('Add Subject'),
                      style: FilledButton.styleFrom(
                        backgroundColor: cc.pri,
                        foregroundColor: cc.priFg,
                      ),
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: subjects.map((subject) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: SpacingTokens.md),
                  child: _buildSubjectCard(theme, cc, subject, userId),
                );
              }).toList(),
            );
          },
          loading: () => const SkeletonList(itemCount: 3),
          error: (_, _) => const EmptySubjects(),
        ),
      ],
    );
  }

  Widget _buildSubjectCard(
    ThemeData theme,
    CCTokens cc,
    SubjectEntity subject,
    String userId,
  ) {
    final typeLabel = subject.type[0].toUpperCase() + subject.type.substring(1);

    return Material(
      color: cc.raise,
      borderRadius: RadiusTokens.borderRadiusLg,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/subject-details/${subject.id}'),
        onLongPress: () => _showSubjectOptions(context, subject, userId),
        child: Padding(
          padding: const EdgeInsets.all(LayoutTokens.cardPadding),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: cc.fg,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.xs),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: SpacingTokens.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: cc.priSoft.withValues(alpha: 0.5),
                            borderRadius: RadiusTokens.borderRadiusSm,
                          ),
                          child: Text(
                            typeLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: cc.pri,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (subject.faculty != null &&
                            subject.faculty!.isNotEmpty) ...[
                          const SizedBox(width: SpacingTokens.sm),
                          Flexible(
                            child: Text(
                              subject.faculty!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cc.mut,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: SpacingTokens.md),
              Icon(Symbols.chevron_right, color: cc.mut),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSemesterTimeline(
    ThemeData theme,
    CCTokens cc,
    SemesterEntity semester,
  ) {
    final startDateStr = semester.startDate;
    final endDateStr = semester.expectedCompletionDate;

    String formatTimelineDate(String? dt) {
      if (dt == null || dt.isEmpty) return 'Unknown';
      try {
        final d = DateTime.parse(dt);
        return DateFormat('d MMM yyyy').format(d);
      } catch (_) {
        return dt;
      }
    }

    final startDisplay = formatTimelineDate(startDateStr);
    final endDisplay = formatTimelineDate(endDateStr);

    return Container(
      padding: const EdgeInsets.all(LayoutTokens.cardPadding),
      decoration: BoxDecoration(
        color: cc.raise,
        borderRadius: RadiusTokens.borderRadiusXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline',
            style: theme.textTheme.titleMedium?.copyWith(
              color: cc.fg,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Start Date',
                style: theme.textTheme.bodyMedium?.copyWith(color: cc.mut),
              ),
              Text(
                startDisplay,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cc.fg,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (endDateStr != null) ...[
            const SizedBox(height: SpacingTokens.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Expected Completion',
                  style: theme.textTheme.bodyMedium?.copyWith(color: cc.mut),
                ),
                Text(
                  endDisplay,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cc.fg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionsSection(
    ThemeData theme,
    CCTokens cc,
    SemesterEntity semester,
    String userId,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: SpacingTokens.sm,
            bottom: SpacingTokens.sm,
          ),
          child: Text(
            'Actions',
            style: theme.textTheme.titleMedium?.copyWith(
              color: cc.fg,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (!semester.isCurrent)
          Padding(
            padding: const EdgeInsets.only(bottom: SpacingTokens.md),
            child: OutlinedButton.icon(
              onPressed: () async {
                await ref
                    .read(semesterRepositoryProvider)
                    .setCurrent(userId, semester.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${semester.name} set as current'),
                      backgroundColor: cc.pri,
                    ),
                  );
                }
              },
              icon: const Icon(Symbols.star, size: 18),
              label: const Text('Set as Current Semester'),
              style: OutlinedButton.styleFrom(
                foregroundColor: cc.pri,
                side: BorderSide(color: cc.pri),
                padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
                shape: const RoundedRectangleBorder(
                  borderRadius: RadiusTokens.borderRadiusMd,
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(bottom: SpacingTokens.md),
          child: OutlinedButton.icon(
            onPressed: () => _showEditSemesterDialog(context, semester, userId),
            icon: const Icon(Symbols.edit, size: 18),
            label: const Text('Edit Semester'),
            style: OutlinedButton.styleFrom(
              foregroundColor: cc.fg,
              side: BorderSide(color: cc.line),
              padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
              shape: const RoundedRectangleBorder(
                borderRadius: RadiusTokens.borderRadiusMd,
              ),
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () async {
            final confirm = await CCDialogs.showDeleteConfirmation(
              context,
              title: 'Delete Semester',
              message:
                  'Are you sure you want to delete "${semester.name}"? All subjects, attendance, and assignments in this semester will also be deleted.',
            );
            if (confirm == true && mounted) {
              await ref
                  .read(semesterRepositoryProvider)
                  .delete(userId, semester.id);
              if (mounted) context.pop();
            }
          },
          icon: const Icon(Symbols.delete, size: 18),
          label: const Text('Delete Semester'),
          style: OutlinedButton.styleFrom(
            foregroundColor: cc.risk,
            side: BorderSide(color: cc.risk),
            padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
            shape: const RoundedRectangleBorder(
              borderRadius: RadiusTokens.borderRadiusMd,
            ),
          ),
        ),
      ],
    );
  }

  // ── Dialogs ──────────────────────────────────────────────────────────────

  void _showAddSubjectDialog(BuildContext context, String userId) {
    final cc = context.cc;
    final nameCtrl = TextEditingController();
    final facultyCtrl = TextEditingController();
    String selectedType = 'theory';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: cc.raise,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: LayoutTokens.screenPadding,
                right: LayoutTokens.screenPadding,
                top: SpacingTokens.lg,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + SpacingTokens.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: cc.mut.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.lg),
                  Text(
                    'Add Subject',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cc.fg,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.lg),
                  TextField(
                    controller: nameCtrl,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Subject Name *',
                      hintText: 'e.g. Data Structures',
                      filled: true,
                      fillColor: cc.raise,
                      border: const OutlineInputBorder(
                        borderRadius: RadiusTokens.borderRadiusMd,
                      ),
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  TextField(
                    controller: facultyCtrl,
                    decoration: InputDecoration(
                      labelText: 'Faculty (Optional)',
                      hintText: 'e.g. Prof. Smith',
                      filled: true,
                      fillColor: cc.raise,
                      border: const OutlineInputBorder(
                        borderRadius: RadiusTokens.borderRadiusMd,
                      ),
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  Text(
                    'Subject Type',
                    style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
                      color: cc.fg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'theory', label: Text('Theory')),
                      ButtonSegment(
                        value: 'practical',
                        label: Text('Practical'),
                      ),
                      ButtonSegment(value: 'tutorial', label: Text('Tutorial')),
                    ],
                    selected: {selectedType},
                    onSelectionChanged: (value) {
                      setSheetState(() => selectedType = value.first);
                    },
                    style: SegmentedButton.styleFrom(
                      selectedForegroundColor: cc.priFg,
                      selectedBackgroundColor: cc.pri,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xl),
                  FilledButton(
                    onPressed: () async {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) return;

                      final now = DateTime.now().toUtc().toIso8601String();
                      final faculty = facultyCtrl.text.trim();
                      await ref
                          .read(subjectRepositoryProvider)
                          .create(
                            SubjectsCompanion(
                              id: Value(const Uuid().v4()),
                              userId: Value(userId),
                              semesterId: Value(widget.semesterId),
                              name: Value(name),
                              faculty: Value(faculty.isEmpty ? null : faculty),
                              type: Value(selectedType),
                              createdAt: Value(now),
                              updatedAt: Value(now),
                            ),
                          );
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: cc.pri,
                      foregroundColor: cc.priFg,
                      padding: const EdgeInsets.symmetric(
                        vertical: SpacingTokens.md,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: RadiusTokens.borderRadiusMd,
                      ),
                    ),
                    child: const Text('Add Subject'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditSemesterDialog(
    BuildContext context,
    SemesterEntity semester,
    String userId,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditSemesterSheet(semester: semester, userId: userId),
    );
  }

  void _showSubjectOptions(
    BuildContext context,
    SubjectEntity subject,
    String userId,
  ) {
    final cc = context.cc;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: cc.raise,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: SpacingTokens.sm),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cc.mut.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LayoutTokens.screenPadding,
                ),
                child: Text(
                  subject.name,
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cc.fg,
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              ListTile(
                leading: Icon(Symbols.edit, color: cc.mut),
                title: const Text('Edit Subject'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showEditSubjectDialog(context, subject, userId);
                },
              ),
              ListTile(
                leading: Icon(Symbols.delete, color: cc.risk),
                title: Text('Delete Subject', style: TextStyle(color: cc.risk)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final confirm = await CCDialogs.showDeleteConfirmation(
                    context,
                    title: 'Delete Subject',
                    message:
                        'Are you sure you want to delete "${subject.name}"? This action cannot be undone.',
                  );
                  if (confirm == true && mounted) {
                    await ref
                        .read(subjectRepositoryProvider)
                        .delete(userId, subject.id);
                  }
                },
              ),
              const SizedBox(height: SpacingTokens.md),
            ],
          ),
        );
      },
    );
  }

  void _showEditSubjectDialog(
    BuildContext context,
    SubjectEntity subject,
    String userId,
  ) {
    final cc = context.cc;
    final nameCtrl = TextEditingController(text: subject.name);
    final facultyCtrl = TextEditingController(text: subject.faculty ?? '');
    String selectedType = subject.type;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: cc.raise,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: LayoutTokens.screenPadding,
                right: LayoutTokens.screenPadding,
                top: SpacingTokens.lg,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + SpacingTokens.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: cc.mut.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.lg),
                  Text(
                    'Edit Subject',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cc.fg,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.lg),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Subject Name *',
                      filled: true,
                      fillColor: cc.raise,
                      border: const OutlineInputBorder(
                        borderRadius: RadiusTokens.borderRadiusMd,
                      ),
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  TextField(
                    controller: facultyCtrl,
                    decoration: InputDecoration(
                      labelText: 'Faculty (Optional)',
                      filled: true,
                      fillColor: cc.raise,
                      border: const OutlineInputBorder(
                        borderRadius: RadiusTokens.borderRadiusMd,
                      ),
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  Text(
                    'Subject Type',
                    style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
                      color: cc.fg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'theory', label: Text('Theory')),
                      ButtonSegment(
                        value: 'practical',
                        label: Text('Practical'),
                      ),
                      ButtonSegment(value: 'tutorial', label: Text('Tutorial')),
                    ],
                    selected: {selectedType},
                    onSelectionChanged: (value) {
                      setSheetState(() => selectedType = value.first);
                    },
                    style: SegmentedButton.styleFrom(
                      selectedForegroundColor: cc.priFg,
                      selectedBackgroundColor: cc.pri,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xl),
                  FilledButton(
                    onPressed: () async {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) return;

                      final faculty = facultyCtrl.text.trim();
                      await ref
                          .read(subjectRepositoryProvider)
                          .update(
                            userId,
                            subject.id,
                            SubjectsCompanion(
                              name: Value(name),
                              faculty: Value(faculty.isEmpty ? null : faculty),
                              type: Value(selectedType),
                              updatedAt: Value(
                                DateTime.now().toUtc().toIso8601String(),
                              ),
                            ),
                          );
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: cc.pri,
                      foregroundColor: cc.priFg,
                      padding: const EdgeInsets.symmetric(
                        vertical: SpacingTokens.md,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: RadiusTokens.borderRadiusMd,
                      ),
                    ),
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _EditSemesterSheet extends ConsumerStatefulWidget {
  const _EditSemesterSheet({required this.semester, required this.userId});

  final SemesterEntity semester;
  final String userId;

  @override
  ConsumerState<_EditSemesterSheet> createState() => _EditSemesterSheetState();
}

class _EditSemesterSheetState extends ConsumerState<_EditSemesterSheet> {
  late final TextEditingController _nameCtrl;
  DateTime? _startDate;
  DateTime? _expectedCompletionDate;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.semester.name);
    _startDate = widget.semester.startDate != null
        ? DateTime.tryParse(widget.semester.startDate!)
        : null;
    _expectedCompletionDate = widget.semester.expectedCompletionDate != null
        ? DateTime.tryParse(widget.semester.expectedCompletionDate!)
        : null;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart
        ? (_startDate ?? DateTime.now())
        : (_expectedCompletionDate ?? _startDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _expectedCompletionDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + SpacingTokens.xl,
        left: SpacingTokens.xl,
        right: SpacingTokens.xl,
        top: SpacingTokens.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: cc.raise,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.xl),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(SpacingTokens.sm),
                decoration: BoxDecoration(
                  color: cc.priSoft.withValues(alpha: 0.5),
                  borderRadius: RadiusTokens.borderRadiusMd,
                ),
                child: Icon(Symbols.edit, color: cc.pri),
              ),
              const SizedBox(width: SpacingTokens.md),
              Text(
                'Edit Semester',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cc.fg,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.lg),
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: 'Semester Name',
              filled: true,
              fillColor: cc.raise2,
              border: const OutlineInputBorder(
                borderRadius: RadiusTokens.borderRadiusLg,
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, true),
                  borderRadius: RadiusTokens.borderRadiusLg,
                  child: Container(
                    padding: const EdgeInsets.all(SpacingTokens.md),
                    decoration: BoxDecoration(
                      color: cc.raise2,
                      borderRadius: RadiusTokens.borderRadiusLg,
                      border: Border.all(
                        color: _startDate != null ? cc.pri : Colors.transparent,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Date',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: cc.mut,
                          ),
                        ),
                        const SizedBox(height: SpacingTokens.xs),
                        Text(
                          _startDate != null
                              ? '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}'
                              : 'Select',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _startDate != null
                                ? cc.fg
                                : cc.mut.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, false),
                  borderRadius: RadiusTokens.borderRadiusLg,
                  child: Container(
                    padding: const EdgeInsets.all(SpacingTokens.md),
                    decoration: BoxDecoration(
                      color: cc.raise2,
                      borderRadius: RadiusTokens.borderRadiusLg,
                      border: Border.all(
                        color: _expectedCompletionDate != null
                            ? cc.pri
                            : Colors.transparent,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'End Date',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: cc.mut,
                          ),
                        ),
                        const SizedBox(height: SpacingTokens.xs),
                        Text(
                          _expectedCompletionDate != null
                              ? '${_expectedCompletionDate!.year}-${_expectedCompletionDate!.month.toString().padLeft(2, '0')}-${_expectedCompletionDate!.day.toString().padLeft(2, '0')}'
                              : 'Select',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _expectedCompletionDate != null
                                ? cc.fg
                                : cc.mut.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.xl),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: SpacingTokens.md,
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: cc.mut,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    final name = _nameCtrl.text.trim();
                    if (name.isNotEmpty) {
                      final now = DateTime.now().toUtc().toIso8601String();
                      final repo = ref.read(semesterRepositoryProvider);
                      await repo.update(
                        widget.userId,
                        widget.semester.id,
                        SemestersCompanion(
                          name: Value(name),
                          updatedAt: Value(now),
                          startDate: _startDate != null
                              ? Value(_startDate!.toUtc().toIso8601String())
                              : const Value<String>.absent(),
                          expectedCompletionDate:
                              _expectedCompletionDate != null
                              ? Value(
                                  _expectedCompletionDate!
                                      .toUtc()
                                      .toIso8601String(),
                                )
                              : const Value<String>.absent(),
                        ),
                      );
                    }
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: cc.pri,
                    padding: const EdgeInsets.symmetric(
                      vertical: SpacingTokens.md,
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
