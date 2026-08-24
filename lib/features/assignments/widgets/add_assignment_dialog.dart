import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/assignments/providers/assignments_provider.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/subjects/providers/subjects_provider.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:uuid/uuid.dart';

class AddAssignmentDialog extends ConsumerStatefulWidget {
  const AddAssignmentDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddAssignmentDialog(),
    );
  }

  @override
  ConsumerState<AddAssignmentDialog> createState() =>
      _AddAssignmentDialogState();
}

class _AddAssignmentDialogState extends ConsumerState<AddAssignmentDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  String? _selectedSubjectId;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _saveAssignment() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an assignment title')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final authState = ref.read(authStateProvider);
      final userId =
          authState is AuthAuthenticated && authState.user.uid.isNotEmpty
          ? authState.user.uid
          : 'default_user';

      final dueStr = DateFormat('yyyy-MM-dd').format(_dueDate);
      final nowIso = DateTime.now().toUtc().toIso8601String();

      final companion = AssignmentsCompanion(
        id: Value(const Uuid().v4()),
        userId: Value(userId),
        subjectId: Value(_selectedSubjectId ?? 'General'),
        title: Value(title),
        description: Value(
          _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
        ),
        dueDate: Value(dueStr),
        status: const Value('pending'),
        createdAt: Value(nowIso),
        updatedAt: Value(nowIso),
      );

      final repo = ref.read(assignmentRepositoryProvider);
      await repo.create(companion);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assignment added successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create assignment: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;
    final authState = ref.watch(authStateProvider);
    final userId =
        authState is AuthAuthenticated && authState.user.uid.isNotEmpty
        ? authState.user.uid
        : 'default_user';

    final subjectsAsync = ref.watch(subjectsStreamProvider(userId));
    final subjects = subjectsAsync.valueOrNull ?? [];

    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.only(top: 60),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        LayoutTokens.screenPadding,
        SpacingTokens.lg,
        LayoutTokens.screenPadding,
        LayoutTokens.screenPadding + bottomPadding,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: cc.mut.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'New Assignment',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cc.fg,
                  ),
                ),
                IconButton(
                  icon: const Icon(Symbols.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.lg),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Assignment Title *',
                hintText: 'e.g. Lab Report 3',
                filled: true,
                fillColor: cc.raise,
                border: const OutlineInputBorder(
                  borderRadius: RadiusTokens.borderRadiusMd,
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            DropdownButtonFormField<String>(
              initialValue:
                  subjects.any(
                    (s) =>
                        s.id == _selectedSubjectId ||
                        s.name == _selectedSubjectId,
                  )
                  ? _selectedSubjectId
                  : null,
              decoration: InputDecoration(
                labelText: 'Subject',
                filled: true,
                fillColor: cc.raise,
                border: const OutlineInputBorder(
                  borderRadius: RadiusTokens.borderRadiusMd,
                ),
              ),
              items: [
                const DropdownMenuItem(
                  value: 'General',
                  child: Text('General'),
                ),
                ...subjects.map(
                  (s) => DropdownMenuItem(value: s.name, child: Text(s.name)),
                ),
              ],
              onChanged: (val) {
                setState(() => _selectedSubjectId = val);
              },
            ),
            const SizedBox(height: SpacingTokens.md),
            InkWell(
              onTap: _pickDueDate,
              borderRadius: RadiusTokens.borderRadiusMd,
              child: Container(
                padding: const EdgeInsets.all(SpacingTokens.md),
                decoration: BoxDecoration(
                  color: cc.raise,
                  borderRadius: RadiusTokens.borderRadiusMd,
                  border: Border.all(color: cc.line),
                ),
                child: Row(
                  children: [
                    Icon(Symbols.calendar_today, color: cc.pri),
                    const SizedBox(width: SpacingTokens.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Due Date',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cc.mut,
                          ),
                        ),
                        Text(
                          DateFormat('EEE, MMM d, yyyy').format(_dueDate),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: cc.fg,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description / Notes (Optional)',
                hintText: 'Add details or requirements...',
                filled: true,
                fillColor: cc.raise,
                border: const OutlineInputBorder(
                  borderRadius: RadiusTokens.borderRadiusMd,
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.xl),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _isSaving ? null : _saveAssignment,
                style: FilledButton.styleFrom(
                  backgroundColor: cc.pri,
                  foregroundColor: cc.priFg,
                  shape: const RoundedRectangleBorder(
                    borderRadius: RadiusTokens.borderRadiusMd,
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Assignment',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
