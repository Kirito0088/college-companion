import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/calendar/providers/calendar_provider.dart';
import 'package:college_companion/features/calendar/widgets/event_type_chip.dart';
import 'package:college_companion/features/subjects/providers/subjects_provider.dart';
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
import 'package:uuid/uuid.dart';

class AddEditEventScreen extends ConsumerStatefulWidget {
  const AddEditEventScreen({super.key});

  @override
  ConsumerState<AddEditEventScreen> createState() => _AddEditEventScreenState();
}

class _AddEditEventScreenState extends ConsumerState<AddEditEventScreen> {
  int _selectedTypeIndex = 0;
  final List<Map<String, dynamic>> _eventTypes = [
    {'label': 'Academic', 'color': ColorTokens.primary},
    {'label': 'Assignment', 'color': ColorTokens.warning},
    {'label': 'Exam', 'color': ColorTokens.error},
    {'label': 'Personal', 'color': ColorTokens.info},
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
      final userId = authState is AuthAuthenticated && authState.user.uid.isNotEmpty
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
      final eventTypeStr = _eventTypes[_selectedTypeIndex]['label'] as String;

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save event: $e')),
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
    final userId = authState is AuthAuthenticated && authState.user.uid.isNotEmpty
        ? authState.user.uid
        : 'default_user';

    final subjectsAsync = ref.watch(subjectsStreamProvider(userId));
    final subjectNames = subjectsAsync.valueOrNull?.map((s) => s.name).toList() ??
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
                    _buildSectionTitle(theme, 'Event Type'),
                    const SizedBox(height: SpacingTokens.sm),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      child: Row(
                        children: List.generate(_eventTypes.length, (index) {
                          final type = _eventTypes[index];
                          return Padding(
                            padding: const EdgeInsets.only(
                              right: SpacingTokens.sm,
                            ),
                            child: EventTypeChip(
                              label: type['label'] as String,
                              color: type['color'] as Color,
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
                      theme: theme,
                      label: 'Title',
                      hint: 'Event title',
                      controller: _titleController,
                    ),
                    const SizedBox(height: SpacingTokens.lg),
                    _buildDropdown(theme: theme, subjects: subjectNames),
                    const SizedBox(height: SpacingTokens.xl),
                    Container(
                      padding: const EdgeInsets.all(SpacingTokens.lg),
                      decoration: BoxDecoration(
                        color: ColorTokens.surfaceContainer,
                        borderRadius: RadiusTokens.borderRadiusLg,
                        border: Border.all(color: ColorTokens.surfaceVariant),
                      ),
                      child: Column(
                        children: [
                          _buildDateTimePicker(
                            theme: theme,
                            label: 'Date',
                            value: dateStr,
                            icon: Symbols.calendar_today,
                            onTap: _pickDate,
                            isCardStyle: false,
                          ),
                          const Divider(
                            height: SpacingTokens.xl,
                            color: ColorTokens.outlineVariant,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDateTimePicker(
                                  theme: theme,
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
                                  theme: theme,
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
                      theme: theme,
                      label: 'Location (Optional)',
                      hint: 'Room, building, or link',
                      controller: _locationController,
                    ),
                    const SizedBox(height: SpacingTokens.lg),
                    _buildTextField(
                      theme: theme,
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
                  backgroundColor: ColorTokens.primary,
                  foregroundColor: ColorTokens.onPrimary,
                  minimumSize: const Size(double.infinity, 56),
                  shape: const RoundedRectangleBorder(
                    borderRadius: RadiusTokens.borderRadiusMd,
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Save Event'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: ColorTokens.onSurfaceVariant,
      ),
    );
  }

  Widget _buildTextField({
    required ThemeData theme,
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(theme, label),
        const SizedBox(height: SpacingTokens.sm),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: ColorTokens.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: ColorTokens.surfaceContainer,
            border: const OutlineInputBorder(
              borderRadius: RadiusTokens.borderRadiusMd,
              borderSide: BorderSide.none,
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: RadiusTokens.borderRadiusMd,
              borderSide: BorderSide(color: ColorTokens.outlineVariant),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: RadiusTokens.borderRadiusMd,
              borderSide: BorderSide(color: ColorTokens.primary),
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

  Widget _buildDropdown({required ThemeData theme, required List<String> subjects}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(theme, 'Linked Subject (Optional)'),
        const SizedBox(height: SpacingTokens.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
          decoration: BoxDecoration(
            color: ColorTokens.surfaceContainer,
            borderRadius: RadiusTokens.borderRadiusMd,
            border: Border.all(color: ColorTokens.outlineVariant),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: subjects.contains(_selectedSubject) ? _selectedSubject : null,
              hint: Text(
                'None',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: ColorTokens.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
              isExpanded: true,
              icon: const Icon(
                Symbols.expand_more,
                color: ColorTokens.onSurfaceVariant,
              ),
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
    required ThemeData theme,
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    bool isCardStyle = true,
  }) {
    final inner = Row(
      children: [
        Icon(icon, size: 20, color: ColorTokens.onSurfaceVariant),
        const SizedBox(width: SpacingTokens.sm),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: ColorTokens.onSurface,
            ),
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(theme, label),
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
                    color: ColorTokens.surfaceContainer,
                    borderRadius: RadiusTokens.borderRadiusMd,
                    border: Border.all(color: ColorTokens.outlineVariant),
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
