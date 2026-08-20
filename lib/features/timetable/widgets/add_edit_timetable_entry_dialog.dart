/// Add / Edit Timetable Entry Dialog
///
/// Modal bottom sheet for adding or updating weekly timetable lecture slots.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/subjects/providers/subjects_provider.dart';
import 'package:college_companion/features/timetable/models/lecture_schedule_item.dart';
import 'package:college_companion/features/timetable/providers/timetable_provider.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:uuid/uuid.dart';

/// Modal dialog for adding or editing a timetable schedule entry.
class AddEditTimetableEntryDialog extends ConsumerStatefulWidget {
  /// Creates an [AddEditTimetableEntryDialog].
  const AddEditTimetableEntryDialog({
    super.key,
    this.initialItem,
    this.initialDay,
  });

  /// The existing schedule entry to edit (null when creating a new entry).
  final LectureScheduleItem? initialItem;

  /// Default day of week if creating a new entry.
  final int? initialDay;

  /// Helper to display this modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    LectureScheduleItem? initialItem,
    int? initialDay,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEditTimetableEntryDialog(
        initialItem: initialItem,
        initialDay: initialDay,
      ),
    );
  }

  @override
  ConsumerState<AddEditTimetableEntryDialog> createState() =>
      _AddEditTimetableEntryDialogState();
}

class _AddEditTimetableEntryDialogState
    extends ConsumerState<AddEditTimetableEntryDialog> {
  final _roomController = TextEditingController();
  final _customSubjectController = TextEditingController();

  String? _selectedSubjectId;
  late int _selectedDayOfWeek;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  String _selectedLectureType = 'theory';
  bool _isSaving = false;

  static const List<String> _dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> _lectureTypes = ['theory', 'practical', 'tutorial'];

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    if (item != null) {
      _selectedSubjectId = item.subjectId;
      _selectedDayOfWeek = item.dayOfWeek;
      _roomController.text = item.room ?? '';
      _selectedLectureType = item.lectureType;
      _startTime = _parseTimeOfDay(item.startTime);
      _endTime = _parseTimeOfDay(item.endTime);
    } else {
      _selectedDayOfWeek = widget.initialDay ?? 0;
    }
  }

  @override
  void dispose() {
    _roomController.dispose();
    _customSubjectController.dispose();
    super.dispose();
  }

  TimeOfDay _parseTimeOfDay(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.isNotEmpty) {
      final hour = int.tryParse(parts[0]) ?? 9;
      final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
      return TimeOfDay(hour: hour, minute: minute);
    }
    return const TimeOfDay(hour: 9, minute: 0);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
        // Auto-advance end time if start time is after end time
        if (_timeToMinutes(_startTime) >= _timeToMinutes(_endTime)) {
          _endTime = TimeOfDay(
            hour: (_startTime.hour + 1) % 24,
            minute: _startTime.minute,
          );
        }
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  int _timeToMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  Future<void> _saveEntry() async {
    final authState = ref.read(authStateProvider);
    final userId =
        authState is AuthAuthenticated && authState.user.uid.isNotEmpty
        ? authState.user.uid
        : 'default_user';

    String? subjectId = _selectedSubjectId;
    if ((subjectId == null || subjectId.isEmpty) &&
        _customSubjectController.text.trim().isNotEmpty) {
      // Auto-create custom subject if needed
      final customName = _customSubjectController.text.trim();
      final nowIso = DateTime.now().toUtc().toIso8601String();
      final newSubjectId = const Uuid().v4();
      final subjectRepo = ref.read(subjectRepositoryProvider);
      await subjectRepo.create(
        SubjectsCompanion(
          id: Value(newSubjectId),
          userId: Value(userId),
          semesterId: const Value('default_sem'),
          name: Value(customName),
          type: Value(_selectedLectureType),
          createdAt: Value(nowIso),
          updatedAt: Value(nowIso),
        ),
      );
      subjectId = newSubjectId;
    }

    if (subjectId == null || subjectId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select or specify a subject')),
        );
      }
      return;
    }

    if (_timeToMinutes(_endTime) <= _timeToMinutes(_startTime)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End time must be after start time')),
        );
      }
      return;
    }

    setState(() => _isSaving = true);

    try {
      final nowIso = DateTime.now().toUtc().toIso8601String();
      final repo = ref.read(timetableRepositoryProvider);
      final room = _roomController.text.trim();

      if (widget.initialItem != null) {
        // Update existing entry
        final entryId = widget.initialItem!.id;
        await repo.update(
          userId,
          entryId,
          TimetableCompanion(
            subjectId: Value(subjectId),
            dayOfWeek: Value(_selectedDayOfWeek),
            startTime: Value(_formatTimeOfDay(_startTime)),
            endTime: Value(_formatTimeOfDay(_endTime)),
            room: Value(room.isNotEmpty ? room : null),
            lectureType: Value(_selectedLectureType),
            updatedAt: Value(nowIso),
          ),
        );
      } else {
        // Create new entry
        final entryId = const Uuid().v4();
        await repo.create(
          TimetableCompanion(
            id: Value(entryId),
            userId: Value(userId),
            subjectId: Value(subjectId),
            dayOfWeek: Value(_selectedDayOfWeek),
            startTime: Value(_formatTimeOfDay(_startTime)),
            endTime: Value(_formatTimeOfDay(_endTime)),
            room: Value(room.isNotEmpty ? room : null),
            lectureType: Value(_selectedLectureType),
            createdAt: Value(nowIso),
            updatedAt: Value(nowIso),
          ),
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.initialItem != null
                  ? 'Timetable entry updated!'
                  : 'Class added to timetable!',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save timetable entry: $e')),
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
    final authState = ref.watch(authStateProvider);
    final userId =
        authState is AuthAuthenticated && authState.user.uid.isNotEmpty
        ? authState.user.uid
        : 'default_user';

    final subjectsAsync = ref.watch(subjectsStreamProvider(userId));
    final subjects = subjectsAsync.valueOrNull ?? [];

    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final isEditing = widget.initialItem != null;

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
            // Drag handle
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: ColorTokens.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Edit Class' : 'Add Class',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ColorTokens.onSurface,
                  ),
                ),
                IconButton(
                  icon: const Icon(Symbols.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.lg),

            // Subject selector
            if (subjects.isNotEmpty)
              DropdownButtonFormField<String>(
                key: const Key('timetable_subject_dropdown'),
                initialValue: subjects.any((s) => s.id == _selectedSubjectId)
                    ? _selectedSubjectId
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Subject *',
                  filled: true,
                  fillColor: ColorTokens.surfaceContainer,
                  border: OutlineInputBorder(
                    borderRadius: RadiusTokens.borderRadiusMd,
                  ),
                ),
                items: subjects
                    .map(
                      (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                    )
                    .toList(),
                onChanged: (val) {
                  setState(() => _selectedSubjectId = val);
                },
              )
            else
              TextField(
                key: const Key('timetable_custom_subject_field'),
                controller: _customSubjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject Name *',
                  hintText: 'e.g. Data Structures',
                  filled: true,
                  fillColor: ColorTokens.surfaceContainer,
                  border: OutlineInputBorder(
                    borderRadius: RadiusTokens.borderRadiusMd,
                  ),
                ),
              ),
            const SizedBox(height: SpacingTokens.md),

            // Day of Week
            DropdownButtonFormField<int>(
              key: const Key('timetable_day_dropdown'),
              initialValue: _selectedDayOfWeek,
              decoration: const InputDecoration(
                labelText: 'Day of Week *',
                filled: true,
                fillColor: ColorTokens.surfaceContainer,
                border: OutlineInputBorder(
                  borderRadius: RadiusTokens.borderRadiusMd,
                ),
              ),
              items: List.generate(
                _dayNames.length,
                (index) => DropdownMenuItem(
                  value: index,
                  child: Text(_dayNames[index]),
                ),
              ),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedDayOfWeek = val);
                }
              },
            ),
            const SizedBox(height: SpacingTokens.md),

            // Time Pickers Row
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickStartTime,
                    borderRadius: RadiusTokens.borderRadiusMd,
                    child: Container(
                      padding: const EdgeInsets.all(SpacingTokens.md),
                      decoration: BoxDecoration(
                        color: ColorTokens.surfaceContainer,
                        borderRadius: RadiusTokens.borderRadiusMd,
                        border: Border.all(color: ColorTokens.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start Time',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: ColorTokens.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: SpacingTokens.xs),
                          Row(
                            children: [
                              const Icon(
                                Symbols.schedule,
                                size: 18,
                                color: ColorTokens.primary,
                              ),
                              const SizedBox(width: SpacingTokens.xs),
                              Text(
                                _startTime.format(context),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: ColorTokens.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: SpacingTokens.md),
                Expanded(
                  child: InkWell(
                    onTap: _pickEndTime,
                    borderRadius: RadiusTokens.borderRadiusMd,
                    child: Container(
                      padding: const EdgeInsets.all(SpacingTokens.md),
                      decoration: BoxDecoration(
                        color: ColorTokens.surfaceContainer,
                        borderRadius: RadiusTokens.borderRadiusMd,
                        border: Border.all(color: ColorTokens.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'End Time',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: ColorTokens.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: SpacingTokens.xs),
                          Row(
                            children: [
                              const Icon(
                                Symbols.schedule,
                                size: 18,
                                color: ColorTokens.primary,
                              ),
                              const SizedBox(width: SpacingTokens.xs),
                              Text(
                                _endTime.format(context),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: ColorTokens.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.md),

            // Room / Hall Identifier
            TextField(
              key: const Key('timetable_room_field'),
              controller: _roomController,
              decoration: const InputDecoration(
                labelText: 'Room / Location (Optional)',
                hintText: 'e.g. Room 302, Lab 1',
                filled: true,
                fillColor: ColorTokens.surfaceContainer,
                border: OutlineInputBorder(
                  borderRadius: RadiusTokens.borderRadiusMd,
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.md),

            // Lecture Type
            DropdownButtonFormField<String>(
              key: const Key('timetable_type_dropdown'),
              initialValue: _selectedLectureType,
              decoration: const InputDecoration(
                labelText: 'Lecture Type',
                filled: true,
                fillColor: ColorTokens.surfaceContainer,
                border: OutlineInputBorder(
                  borderRadius: RadiusTokens.borderRadiusMd,
                ),
              ),
              items: _lectureTypes
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(type[0].toUpperCase() + type.substring(1)),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedLectureType = val);
                }
              },
            ),
            const SizedBox(height: SpacingTokens.xl),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                key: const Key('timetable_save_button'),
                onPressed: _isSaving ? null : _saveEntry,
                style: FilledButton.styleFrom(
                  backgroundColor: ColorTokens.primary,
                  foregroundColor: ColorTokens.onPrimary,
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
                    : Text(
                        isEditing ? 'Save Changes' : 'Add to Timetable',
                        style: const TextStyle(
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
