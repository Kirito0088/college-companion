import 'package:college_companion/shared/widgets/cc_card.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class ManageModulesScreen extends StatefulWidget {
  const ManageModulesScreen({super.key});

  @override
  State<ManageModulesScreen> createState() => _ManageModulesScreenState();
}

class _ManageModulesScreenState extends State<ManageModulesScreen> {
  String _selectedSemester = 'Semester 6';
  final List<String> _semesters = [
    'Semester 5',
    'Semester 6',
    'Semester 7',
    'Semester 8',
  ];

  final List<Map<String, dynamic>> _modules = [
    {
      'code': 'CS301',
      'name': 'Data Structures & Algorithms',
      'credits': 4,
      'type': 'Core',
      'isActive': true,
    },
    {
      'code': 'CS302',
      'name': 'Database Management Systems',
      'credits': 4,
      'type': 'Core',
      'isActive': true,
    },
    {
      'code': 'CS303',
      'name': 'Operating Systems',
      'credits': 3,
      'type': 'Core',
      'isActive': false,
    },
    {
      'code': 'HU301',
      'name': 'Engineering Economics',
      'credits': 2,
      'type': 'Elective',
      'isActive': true,
    },
    {
      'code': 'CS304',
      'name': 'Computer Networks',
      'credits': 4,
      'type': 'Core',
      'isActive': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          'Manage Modules',
          style: theme.textTheme.titleLarge?.copyWith(
            color: ColorTokens.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(context),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(LayoutTokens.screenPadding),
              itemCount: _modules.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: SpacingTokens.md),
              itemBuilder: (context, index) {
                final module = _modules[index];
                return _ModuleCard(
                  code: module['code'] as String,
                  name: module['name'] as String,
                  credits: module['credits'] as int,
                  type: module['type'] as String,
                  isActive: module['isActive'] as bool,
                  onToggle: (val) {
                    setState(() {
                      module['isActive'] = val;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(context),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LayoutTokens.screenPadding,
        vertical: SpacingTokens.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: ColorTokens.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _semesters.map((sem) {
                final isSelected = _selectedSemester == sem;
                return Padding(
                  padding: const EdgeInsets.only(right: SpacingTokens.sm),
                  child: FilterChip(
                    selected: isSelected,
                    showCheckmark: false,
                    label: Text(
                      sem,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: isSelected
                            ? ColorTokens.onPrimary
                            : ColorTokens.onSurfaceVariant,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                    backgroundColor: ColorTokens.surfaceContainer,
                    selectedColor: ColorTokens.primary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: RadiusTokens.borderRadiusMd,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? Colors.transparent
                          : ColorTokens.outlineVariant,
                    ),
                    onSelected: (val) {
                      setState(() {
                        _selectedSemester = sem;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search modules...',
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: ColorTokens.onSurfaceVariant,
              ),
              prefixIcon: const Icon(
                Symbols.search,
                color: ColorTokens.onSurfaceVariant,
              ),
              filled: true,
              fillColor: ColorTokens.surfaceContainer,
              border: const OutlineInputBorder(
                borderRadius: RadiusTokens.borderRadiusLg,
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: SpacingTokens.md,
                horizontal: SpacingTokens.md,
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LayoutTokens.screenPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: ColorTokens.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.primary,
              foregroundColor: ColorTokens.onPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
              shape: const RoundedRectangleBorder(
                borderRadius: RadiusTokens.borderRadiusLg,
              ),
            ),
            child: const Text(
              'Save Changes',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.code,
    required this.name,
    required this.credits,
    required this.type,
    required this.isActive,
    required this.onToggle,
  });

  final String code;
  final String name;
  final int credits;
  final String type;
  final bool isActive;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CCCard(
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isActive
                ? ColorTokens.primary.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 2,
          ),
          borderRadius: RadiusTokens.borderRadiusXl,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onToggle(!isActive),
            borderRadius: RadiusTokens.borderRadiusXl,
            child: Padding(
              padding: const EdgeInsets.all(SpacingTokens.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: SpacingTokens.sm,
                                vertical: 2,
                              ),
                              decoration: const BoxDecoration(
                                color: ColorTokens.surfaceContainerHigh,
                                borderRadius: RadiusTokens.borderRadiusSm,
                              ),
                              child: Text(
                                code,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: ColorTokens.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: SpacingTokens.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: SpacingTokens.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: type == 'Core'
                                    ? ColorTokens.primaryContainer
                                    : ColorTokens.tertiaryContainer,
                                borderRadius: RadiusTokens.borderRadiusSm,
                              ),
                              child: Text(
                                type,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: type == 'Core'
                                      ? ColorTokens.onPrimaryContainer
                                      : ColorTokens.onTertiaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: SpacingTokens.sm),
                        Text(
                          name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: ColorTokens.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: SpacingTokens.xs),
                        Text(
                          '$credits Credits',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: ColorTokens.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Switch(
                        value: isActive,
                        onChanged: onToggle,
                        activeThumbColor: ColorTokens.surface,
                        activeTrackColor: ColorTokens.primary,
                        inactiveThumbColor: ColorTokens.outline,
                        inactiveTrackColor: ColorTokens.surfaceContainerHighest,
                      ),
                      const SizedBox(height: SpacingTokens.xs),
                      Text(
                        isActive ? 'Active' : 'Inactive',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: isActive
                              ? ColorTokens.primary
                              : ColorTokens.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
