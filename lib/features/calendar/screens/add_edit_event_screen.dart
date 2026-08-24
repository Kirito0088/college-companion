import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/calendar/providers/calendar_provider.dart';
import 'package:college_companion/features/calendar/widgets/agenda_card.dart';
import 'package:college_companion/features/calendar/widgets/event_type_chip.dart';
import 'package:college_companion/features/subjects/providers/subjects_provider.dart';
import 'package:college_companion/shared/widgets/dialogs/cc_dialogs.dart';
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

class AddEditEventScreen extends ConsumerStatefulWidget {
  const AddEditEventScreen({super.key});

  @override
  ConsumerState<AddEditEventScreen> createState() => _AddEditEventScreenState();
}

class _AddEditEventScreenState extends ConsumerState<AddEditEventScreen> {
  int _selectedTypeIndex = 0;

  /// Type key -> display label. Colors are resolved at build time via
  /// [calendarEventTypeColor], the same function every other calendar
  /// surface uses, so the picker matches what the saved event renders as.
  static const List<(String key, String label)> _eventTypes = [
    ('academic', 'Academic'),
    ('assignment', 'Assignment'),
    ('exam', 'Exam'),
    ('personal', 'Personal'),
  ];

  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 12, minute: 0);
  String? _selectedSubject;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  Future<void> _saveEvent() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an event title')),
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

      final startDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _startTime.hour,
        _startTime.minute,
      );

      final endDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _endTime.hour,
        _endTime.minute,
      );

      final nowIso = DateTime.now().toUtc().toIso8601String();
      final eventTypeStr = _eventTypes[_selectedTypeIndex].$1;

      final notesText = _notesController.text.trim();
      final locText = _locationController.text.trim();
      final fullDesc = [
        if (locText.isNotEmpty) 'Location: $locText',
        if (_selectedSubject != null) 'Subject: $_selectedSubject',
        if (notesText.isNotEmpty) notesText,
      ].join('\n');

      final companion = CalendarEventsCompanion(
        id: Value(const Uuid().v4()),
        userId: Value(userId),
        title: Value(title),
        description: Value(fullDesc.isNotEmpty ? fullDesc : null),
        startDate: Value(startDateTime.toUtc().toIso8601String()),
        endDate: Value(endDateTime.toUtc().toIso8601String()),
        isAllDay: const Value(false),
        eventType: Value(eventTypeStr),
        createdAt: Value(nowIso),
        updatedAt: Value(nowIso),
      );

      final repo = ref.read(calendarRepositoryProvider);
      await repo.create(companion);

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save event: $e')));
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
    final subjectNames =
        subjectsAsync.valueOrNull?.map((s) => s.name).toList() ??
        ['Physics 101', 'DBMS', 'Web Technology', 'Computer Science'];

    final dateStr = DateFormat('MMM d, yyyy').format(_selectedDate);
    final startTimeStr = _startTime.format(context);
    final endTimeStr = _endTime.format(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Symbols.close),
          onPressed: () async {
            final discard = await CCDialogs.showDiscardChanges(context);
            if (discard == true) {
              if (context.mounted) {
                context.pop();
              }
            }
          },
        ),
        title: Text(
          'New Event',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(LayoutTokens.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionTitle(context, 'Event Type'),
                    const SizedBox(height: SpacingTokens.sm),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      child: Row(
                        children: List.generate(_eventTypes.length, (index) {
                          final (key, label) = _eventTypes[index];
                          return Padding(
                            padding: const EdgeInsets.only(
                              right: SpacingTokens.sm,
                            ),
                            child: EventTypeChip(
                              label: label,
                              color: calendarEventTypeColor(context, key),
                              isSelected: _selectedTypeIndex == index,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedTypeIndex = index;
                                  });
                                }
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.xl),
                    _buildTextField(
                      context: context,
                      label: 'Title',
                      hint: 'Event title',
                      controller: _titleController,
                    ),
                    const SizedBox(height: SpacingTokens.lg),
                    _buildDropdown(context: context, subjects: subjectNames),
                    const SizedBox(height: SpacingTokens.xl),
                    Container(
                      padding: const EdgeInsets.all(SpacingTokens.lg),
                      decoration: BoxDecoration(
                        color: cc.raise,
                        borderRadius: RadiusTokens.borderRadiusXxl,
                        border: Border.all(color: cc.line),
                      ),
                      child: Column(
                        children: [
                          _buildDateTimePicker(
                            context: context,
                            label: 'Date',
                            value: dateStr,
                            icon: Symbols.calendar_today,
                            onTap: _pickDate,
                            isCardStyle: false,
                          ),
                          Divider(height: SpacingTokens.xl, color: cc.line),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDateTimePicker(
                                  context: context,
                                  label: 'Start Time',
                                  value: startTimeStr,
                                  icon: Symbols.schedule,
                                  onTap: _pickStartTime,
                                  isCardStyle: false,
                                ),
                              ),
                              const SizedBox(width: SpacingTokens.md),
                              Expanded(
                                child: _buildDateTimePicker(
                                  context: context,
                                  label: 'End Time',
                                  value: endTimeStr,
                                  icon: Symbols.schedule,
                                  onTap: _pickEndTime,
                                  isCardStyle: false,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.xl),
                    _buildTextField(
                      context: context,
                      label: 'Location (Optional)',
                      hint: 'Room, building, or link',
                      controller: _locationController,
                    ),
                    const SizedBox(height: SpacingTokens.lg),
                    _buildTextField(
                      context: context,
                      label: 'Notes (Optional)',
                      hint: 'Add any extra details here...',
                      controller: _notesController,
                      maxLines: 4,
                    ),
                    const SizedBox(height: SpacingTokens.xxl),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(LayoutTokens.screenPadding),
              child: FilledButton(
                onPressed: _isSaving ? null : _saveEvent,
                style: FilledButton.styleFrom(
                  backgroundColor: cc.pri,
                  foregroundColor: cc.priFg,
                  minimumSize: const Size(double.infinity, 56),
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
                    : const Text('Save Event'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    final cc = context.cc;
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: cc.mut,
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    final cc = context.cc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, label),
        const SizedBox(height: SpacingTokens.sm),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: cc.mut.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: cc.raise,
            border: const OutlineInputBorder(
              borderRadius: RadiusTokens.borderRadiusMd,
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: RadiusTokens.borderRadiusMd,
              borderSide: BorderSide(color: cc.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: RadiusTokens.borderRadiusMd,
              borderSide: BorderSide(color: cc.pri),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.lg,
              vertical: SpacingTokens.md,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required BuildContext context,
    required List<String> subjects,
  }) {
    final theme = Theme.of(context);
    final cc = context.cc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Linked Subject (Optional)'),
        const SizedBox(height: SpacingTokens.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
          decoration: BoxDecoration(
            color: cc.raise,
            borderRadius: RadiusTokens.borderRadiusMd,
            border: Border.all(color: cc.line),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: subjects.contains(_selectedSubject)
                  ? _selectedSubject
                  : null,
              hint: Text(
                'None',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: cc.mut.withValues(alpha: 0.5),
                ),
              ),
              isExpanded: true,
              icon: Icon(Symbols.expand_more, color: cc.mut),
              items: subjects.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedSubject = newValue;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimePicker({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    bool isCardStyle = true,
  }) {
    final theme = Theme.of(context);
    final cc = context.cc;
    final inner = Row(
      children: [
        Icon(icon, size: 20, color: cc.mut),
        const SizedBox(width: SpacingTokens.sm),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(color: cc.fg),
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, label),
        const SizedBox(height: SpacingTokens.sm),
        InkWell(
          onTap: onTap,
          borderRadius: RadiusTokens.borderRadiusMd,
          child: isCardStyle
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.lg,
                    vertical: SpacingTokens.md,
                  ),
                  decoration: BoxDecoration(
                    color: cc.raise,
                    borderRadius: RadiusTokens.borderRadiusMd,
                    border: Border.all(color: cc.line),
                  ),
                  child: inner,
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: SpacingTokens.xs,
                  ),
                  child: inner,
                ),
        ),
      ],
    );
  }
}
