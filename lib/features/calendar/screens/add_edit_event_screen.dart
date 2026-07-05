import 'package:college_companion/features/calendar/widgets/event_type_chip.dart';
import 'package:college_companion/shared/widgets/dialogs/cc_dialogs.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class AddEditEventScreen extends StatefulWidget {
  const AddEditEventScreen({super.key});

  @override
  State<AddEditEventScreen> createState() => _AddEditEventScreenState();
}

class _AddEditEventScreenState extends State<AddEditEventScreen> {
  int _selectedTypeIndex = 0;
  final List<Map<String, dynamic>> _eventTypes = [
    {'label': 'Academic', 'color': ColorTokens.primary},
    {'label': 'Assignment', 'color': ColorTokens.warning},
    {'label': 'Exam', 'color': ColorTokens.error},
    {'label': 'Personal', 'color': ColorTokens.info},
  ];

  String? _selectedSubject;
  final List<String> _subjects = [
    'Physics 101',
    'DBMS',
    'Web Technology',
    'Computer Science',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          'New Event', // Or 'Edit Event' based on param in real app
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
                    ),
                    const SizedBox(height: SpacingTokens.lg),
                    _buildDropdown(theme: theme),
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
                            value: 'May 14, 2025',
                            icon: Symbols.calendar_today,
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
                                  value: '10:00 AM',
                                  icon: Symbols.schedule,
                                  isCardStyle: false,
                                ),
                              ),
                              const SizedBox(width: SpacingTokens.md),
                              Expanded(
                                child: _buildDateTimePicker(
                                  theme: theme,
                                  label: 'End Time',
                                  value: '12:00 PM',
                                  icon: Symbols.schedule,
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
                    ),
                    const SizedBox(height: SpacingTokens.lg),
                    _buildTextField(
                      theme: theme,
                      label: 'Notes (Optional)',
                      hint: 'Add any extra details here...',
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
                onPressed: () {
                  context.pop();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: ColorTokens.primary,
                  foregroundColor: ColorTokens.onPrimary,
                  minimumSize: const Size(double.infinity, 56),
                  shape: const RoundedRectangleBorder(
                    borderRadius: RadiusTokens.borderRadiusMd,
                  ),
                ),
                child: const Text('Save Event'),
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
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(theme, label),
        const SizedBox(height: SpacingTokens.sm),
        TextField(
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

  Widget _buildDropdown({required ThemeData theme}) {
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
              value: _selectedSubject,
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
              items: _subjects.map((String value) {
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
          onTap: () {},
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
