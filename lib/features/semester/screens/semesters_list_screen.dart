import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/semester/providers/semester_provider.dart';
import 'package:college_companion/shared/widgets/empty_states/cc_empty_states.dart';
import 'package:college_companion/shared/widgets/errors/cc_errors.dart';
import 'package:college_companion/shared/widgets/loading/cc_skeletons.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:uuid/uuid.dart';

class SemestersListScreen extends ConsumerWidget {
  const SemestersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final userId = authState is AuthAuthenticated && authState.user.uid.isNotEmpty
        ? authState.user.uid
        : 'default_user';

    final semestersAsync = ref.watch(semestersStreamProvider(userId));

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
          'Semesters',
          style: theme.textTheme.titleLarge?.copyWith(
            color: ColorTokens.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: semestersAsync.when(
        data: (semesters) {
          if (semesters.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(LayoutTokens.screenPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const EmptySubjects(),
                    const SizedBox(height: SpacingTokens.lg),
                    FilledButton.icon(
                      onPressed: () => _showAddSemesterDialog(context, ref, userId),
                      icon: const Icon(Symbols.add),
                      label: const Text('Add First Semester'),
                      style: FilledButton.styleFrom(
                        backgroundColor: ColorTokens.primary,
                        foregroundColor: ColorTokens.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: LayoutTokens.screenPadding,
              vertical: SpacingTokens.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                const SizedBox(height: LayoutTokens.sectionGap),
                ...semesters.map(
                  (semester) => Padding(
                    padding: const EdgeInsets.only(bottom: SpacingTokens.md),
                    child: _SemesterCard(semester: semester),
                  ),
                ),
                const SizedBox(height: SpacingTokens.xxl),
              ],
            ),
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(horizontal: LayoutTokens.screenPadding),
          child: SkeletonList(),
        ),
        error: (err, stack) => NetworkErrorWidget(
          onRetry: () => ref.invalidate(semestersStreamProvider(userId)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSemesterDialog(context, ref, userId),
        backgroundColor: ColorTokens.primary,
        foregroundColor: ColorTokens.onPrimary,
        child: const Icon(Symbols.add),
      ),
    );
  }

  void _showAddSemesterDialog(BuildContext context, WidgetRef ref, String userId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddSemesterSheet(userId: userId),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your academic journey.',
          style: theme.textTheme.titleMedium?.copyWith(
            color: ColorTokens.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          'Track every semester in one place.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: ColorTokens.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SemesterCard extends StatelessWidget {
  const _SemesterCard({required this.semester});

  final SemesterEntity semester;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: ColorTokens.surfaceContainer,
      borderRadius: RadiusTokens.borderRadiusXl,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/semester-details/${semester.id}'),
        child: Padding(
          padding: const EdgeInsets.all(LayoutTokens.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          semester.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: ColorTokens.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: SpacingTokens.xs),
                        Text(
                          'Created ${semester.createdAt.split('T')[0]}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: ColorTokens.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const _StatusBadge(status: 'Active'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.xs,
      ),
      decoration: BoxDecoration(
        color: ColorTokens.primaryContainer.withValues(alpha: 0.6),
        borderRadius: RadiusTokens.borderRadiusSm,
      ),
      child: Text(
        status.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: ColorTokens.onPrimaryContainer,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _AddSemesterSheet extends ConsumerStatefulWidget {
  const _AddSemesterSheet({required this.userId});
  final String userId;

  @override
  ConsumerState<_AddSemesterSheet> createState() => _AddSemesterSheetState();
}

class _AddSemesterSheetState extends ConsumerState<_AddSemesterSheet> {
  final _nameCtrl = TextEditingController();
  DateTime? _startDate;
  DateTime? _expectedCompletionDate;

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
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: ColorTokens.primary,
              onPrimary: ColorTokens.onPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_expectedCompletionDate != null && picked.isAfter(_expectedCompletionDate!)) {
            _expectedCompletionDate = null;
          }
        } else {
          _expectedCompletionDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: EdgeInsets.only(
        left: SpacingTokens.md,
        right: SpacingTokens.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + SpacingTokens.md,
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
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xl),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(SpacingTokens.sm),
                  decoration: BoxDecoration(
                    color: ColorTokens.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: RadiusTokens.borderRadiusMd,
                  ),
                  child: const Icon(Symbols.school, color: ColorTokens.primary),
                ),
                const SizedBox(width: SpacingTokens.md),
                Text(
                  'Create Semester',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ColorTokens.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xl),
            child: TextField(
              controller: _nameCtrl,
              autofocus: true,
              style: theme.textTheme.bodyLarge?.copyWith(color: ColorTokens.onSurface),
              decoration: const InputDecoration(
                labelText: 'Semester Name',
                hintText: 'e.g. Semester 5, Fall 2026',
                filled: true,
                fillColor: ColorTokens.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderRadius: RadiusTokens.borderRadiusLg,
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xl),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    borderRadius: RadiusTokens.borderRadiusLg,
                    child: Container(
                      padding: const EdgeInsets.all(SpacingTokens.md),
                      decoration: BoxDecoration(
                        color: ColorTokens.surfaceContainerHigh,
                        borderRadius: RadiusTokens.borderRadiusLg,
                        border: Border.all(
                          color: _startDate != null ? ColorTokens.primary : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Start Date', style: theme.textTheme.labelMedium?.copyWith(color: ColorTokens.onSurfaceVariant)),
                          const SizedBox(height: SpacingTokens.xs),
                          Text(
                            _startDate != null ? '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}' : 'Select',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: _startDate != null ? ColorTokens.onSurface : ColorTokens.onSurfaceVariant.withValues(alpha: 0.5),
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
                        color: ColorTokens.surfaceContainerHigh,
                        borderRadius: RadiusTokens.borderRadiusLg,
                        border: Border.all(
                          color: _expectedCompletionDate != null ? ColorTokens.primary : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('End Date', style: theme.textTheme.labelMedium?.copyWith(color: ColorTokens.onSurfaceVariant)),
                          const SizedBox(height: SpacingTokens.xs),
                          Text(
                            _expectedCompletionDate != null ? '${_expectedCompletionDate!.year}-${_expectedCompletionDate!.month.toString().padLeft(2, '0')}-${_expectedCompletionDate!.day.toString().padLeft(2, '0')}' : 'Select',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: _expectedCompletionDate != null ? ColorTokens.onSurface : ColorTokens.onSurfaceVariant.withValues(alpha: 0.5),
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
          ),
          const SizedBox(height: SpacingTokens.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xl),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: ColorTokens.onSurfaceVariant, fontWeight: FontWeight.w600)),
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
                        await repo.create(
                          SemestersCompanion(
                            id: drift.Value(const Uuid().v4()),
                            userId: drift.Value(widget.userId),
                            name: drift.Value(name),
                            workingDays: const drift.Value('[0,1,2,3,4]'),
                            createdAt: drift.Value(now),
                            updatedAt: drift.Value(now),
                            startDate: _startDate != null ? drift.Value(_startDate!.toUtc().toIso8601String()) : const drift.Value<String>.absent(),
                            expectedCompletionDate: _expectedCompletionDate != null ? drift.Value(_expectedCompletionDate!.toUtc().toIso8601String()) : const drift.Value<String>.absent(),
                          ),
                        );
                      }
                      if (context.mounted) Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: ColorTokens.primary,
                      foregroundColor: ColorTokens.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Create', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.xl),
        ],
      ),
    );
  }
}
