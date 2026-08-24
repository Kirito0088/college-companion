import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/icon_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Modal bottom sheet for marking or editing an attendance record.
class MarkAttendanceSheet extends StatefulWidget {
  const MarkAttendanceSheet({
    super.key,
    required this.onSave,
    this.initialStatus = 'present',
    this.initialLectureType = 'theory',
    this.initialNotes,
    this.initialDate,
  });

  final Future<void> Function({
    required String status,
    required DateTime date,
    required String lectureType,
    String? notes,
  })
  onSave;

  final String initialStatus;
  final String initialLectureType;
  final String? initialNotes;
  final DateTime? initialDate;

  static Future<void> show(
    BuildContext context, {
    required Future<void> Function({
      required String status,
      required DateTime date,
      required String lectureType,
      String? notes,
    })
    onSave,
    String initialStatus = 'present',
    String initialLectureType = 'theory',
    String? initialNotes,
    DateTime? initialDate,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cc.surf,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(RadiusTokens.xl),
        ),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: MarkAttendanceSheet(
          onSave: onSave,
          initialStatus: initialStatus,
          initialLectureType: initialLectureType,
          initialNotes: initialNotes,
          initialDate: initialDate,
        ),
      ),
    );
  }

  @override
  State<MarkAttendanceSheet> createState() => _MarkAttendanceSheetState();
}

class _MarkAttendanceSheetState extends State<MarkAttendanceSheet> {
  late String _selectedStatus;
  late String _selectedLectureType;
  late DateTime _selectedDate;
  late final TextEditingController _notesController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus;
    _selectedLectureType = widget.initialLectureType;
    _selectedDate = widget.initialDate ?? DateTime.now();
    _notesController = TextEditingController(text: widget.initialNotes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onSave(
        status: _selectedStatus,
        date: _selectedDate,
        lectureType: _selectedLectureType,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: LayoutTokens.screenPadding,
          vertical: SpacingTokens.lg,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cc.line2,
                    borderRadius: RadiusTokens.borderRadiusPill,
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.base),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mark Attendance',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: cc.fg,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Symbols.close, size: IconSizeTokens.md),
                    color: cc.mut,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.md),

              // Status Selector
              Text(
                'Status',
                style: theme.textTheme.labelMedium?.copyWith(color: cc.mut),
              ),
              const SizedBox(height: SpacingTokens.sm),
              Row(
                children: [
                  Expanded(
                    child: _buildStatusChoice(
                      key: const Key('status_present_option'),
                      label: 'Present',
                      value: 'present',
                      icon: Symbols.check_circle,
                      color: cc.pri,
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    child: _buildStatusChoice(
                      key: const Key('status_absent_option'),
                      label: 'Absent',
                      value: 'absent',
                      icon: Symbols.cancel,
                      color: cc.risk,
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    child: _buildStatusChoice(
                      key: const Key('status_cancelled_option'),
                      label: 'Cancelled',
                      value: 'cancelled',
                      icon: Symbols.event_busy,
                      color: cc.mut,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.lg),

              // Date Picker Field
              Text(
                'Date',
                style: theme.textTheme.labelMedium?.copyWith(color: cc.mut),
              ),
              const SizedBox(height: SpacingTokens.sm),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
                borderRadius: RadiusTokens.borderRadiusMd,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.base,
                    vertical: SpacingTokens.md,
                  ),
                  decoration: BoxDecoration(
                    color: cc.raise,
                    borderRadius: RadiusTokens.borderRadiusMd,
                    border: Border.all(color: cc.line),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cc.fg,
                        ),
                      ),
                      Icon(
                        Symbols.calendar_today,
                        size: IconSizeTokens.sm,
                        color: cc.mut,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.lg),

              // Lecture Type
              Text(
                'Lecture Type',
                style: theme.textTheme.labelMedium?.copyWith(color: cc.mut),
              ),
              const SizedBox(height: SpacingTokens.sm),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'theory',
                    label: Text('Theory'),
                    icon: Icon(Symbols.menu_book, size: IconSizeTokens.sm),
                  ),
                  ButtonSegment(
                    value: 'practical',
                    label: Text('Lab'),
                    icon: Icon(Symbols.science, size: IconSizeTokens.sm),
                  ),
                  ButtonSegment(
                    value: 'tutorial',
                    label: Text('Tutorial'),
                    icon: Icon(Symbols.group, size: IconSizeTokens.sm),
                  ),
                ],
                selected: {_selectedLectureType},
                onSelectionChanged: (set) {
                  setState(() {
                    _selectedLectureType = set.first;
                  });
                },
              ),
              const SizedBox(height: SpacingTokens.lg),

              // Notes
              Text(
                'Topic / Notes (Optional)',
                style: theme.textTheme.labelMedium?.copyWith(color: cc.mut),
              ),
              const SizedBox(height: SpacingTokens.sm),
              TextField(
                key: const Key('attendance_notes_field'),
                controller: _notesController,
                style: theme.textTheme.bodyMedium?.copyWith(color: cc.fg),
                decoration: InputDecoration(
                  hintText: 'e.g. Binary Search Trees',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: cc.mut,
                  ),
                  filled: true,
                  fillColor: cc.raise,
                  border: OutlineInputBorder(
                    borderRadius: RadiusTokens.borderRadiusMd,
                    borderSide: BorderSide(color: cc.line),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: RadiusTokens.borderRadiusMd,
                    borderSide: BorderSide(color: cc.line),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: RadiusTokens.borderRadiusMd,
                    borderSide: BorderSide(color: cc.pri),
                  ),
                  contentPadding: const EdgeInsets.all(SpacingTokens.base),
                ),
              ),
              const SizedBox(height: SpacingTokens.xl),

              // Save button
              FilledButton(
                key: const Key('save_attendance_button'),
                onPressed: _isSaving ? null : _handleSave,
                style: FilledButton.styleFrom(
                  backgroundColor: cc.pri,
                  foregroundColor: cc.priFg,
                  padding: const EdgeInsets.symmetric(
                    vertical: SpacingTokens.base,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: RadiusTokens.borderRadiusMd,
                  ),
                ),
                child: _isSaving
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: cc.priFg,
                        ),
                      )
                    : Text(
                        'Save Attendance',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: cc.priFg,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChoice({
    required Key key,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedStatus == value;
    final theme = Theme.of(context);
    final cc = context.cc;

    return InkWell(
      key: key,
      onTap: () {
        setState(() {
          _selectedStatus = value;
        });
      },
      borderRadius: RadiusTokens.borderRadiusMd,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: SpacingTokens.md,
          horizontal: SpacingTokens.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : cc.raise,
          borderRadius: RadiusTokens.borderRadiusMd,
          border: Border.all(
            color: isSelected ? color : cc.line,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: IconSizeTokens.md,
              color: isSelected ? color : cc.mut,
            ),
            const SizedBox(height: SpacingTokens.xs),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected ? color : cc.mut,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
