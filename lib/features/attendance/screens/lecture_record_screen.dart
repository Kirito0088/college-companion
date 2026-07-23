import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/attendance/providers/attendance_provider.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:uuid/uuid.dart';

enum PrimaryStatus { present, absent, cancelled }

enum SecondaryStatus {
  facultyAbsent('Faculty Absent'),
  holiday('Holiday'),
  practicalCancelled('Practical Cancelled'),
  extraLecture('Extra Lecture'),
  other('Other');

  const SecondaryStatus(this.label);
  final String label;
}

class LectureRecordScreen extends ConsumerStatefulWidget {
  const LectureRecordScreen({super.key});

  @override
  ConsumerState<LectureRecordScreen> createState() => _LectureRecordScreenState();
}

class _LectureRecordScreenState extends ConsumerState<LectureRecordScreen> {
  PrimaryStatus? _primaryStatus;
  SecondaryStatus? _secondaryStatus;
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _otherReasonController = TextEditingController();
  final FocusNode _otherFocusNode = FocusNode();

  @override
  void dispose() {
    _noteController.dispose();
    _otherReasonController.dispose();
    _otherFocusNode.dispose();
    super.dispose();
  }

  void _selectPrimaryStatus(PrimaryStatus status) {
    setState(() {
      _primaryStatus = status;
      // Reset secondary status when primary changes
      _secondaryStatus = null;
    });
  }

  void _selectSecondaryStatus(SecondaryStatus status) {
    setState(() {
      _secondaryStatus = status;
    });
    if (status == SecondaryStatus.other) {
      // Small delay to allow AnimatedSize to expand before focusing
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _otherFocusNode.requestFocus();
      });
    } else {
      _otherFocusNode.unfocus();
    }
  }

  List<SecondaryStatus> get _availableSecondaryStatuses {
    switch (_primaryStatus) {
      case PrimaryStatus.present:
        return [SecondaryStatus.other];
      case PrimaryStatus.absent:
        return [
          SecondaryStatus.holiday,
          SecondaryStatus.facultyAbsent,
          SecondaryStatus.other,
        ];
      case PrimaryStatus.cancelled:
        return [
          SecondaryStatus.facultyAbsent,
          SecondaryStatus.practicalCancelled,
          SecondaryStatus.extraLecture,
          SecondaryStatus.other,
        ];
      case null:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Symbols.close, color: ColorTokens.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          // Main Scrollable Content
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: LayoutTokens.screenPadding,
                right: LayoutTokens.screenPadding,
                top: SpacingTokens.sm,
                bottom: 200, // Space for sticky bottom bar
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeroAnchor(theme),
                  const SizedBox(height: SpacingTokens.xxl),
                  _buildLectureInformation(theme),
                  const SizedBox(height: SpacingTokens.xxl),
                  _buildPrimaryStatusSection(theme),
                  _buildSecondaryStatusSection(theme),
                  const SizedBox(height: SpacingTokens.xxl),
                  _buildOptionalNote(theme),
                  const SizedBox(height: SpacingTokens.xxl),
                  _buildEvidenceSection(theme),
                  SizedBox(height: bottomPadding), // Keyboard avoidance
                ],
              ),
            ),
          ),

          // Sticky Bottom Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildStickySaveBar(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroAnchor(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            decoration: BoxDecoration(
              color: ColorTokens.surfaceContainerHighest,
              shape: BoxShape.circle,
              border: Border.all(color: ColorTokens.outlineVariant, width: 1),
            ),
            child: const Icon(
              Symbols.history_edu,
              size: 32,
              color: ColorTokens.primary,
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          Text(
            'Lecture Record',
            style: theme.textTheme.titleMedium?.copyWith(
              color: ColorTokens.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLectureInformation(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        color: ColorTokens.surfaceContainerHigh,
        borderRadius: RadiusTokens.borderRadiusXl,
        border: Border.all(color: ColorTokens.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advanced Mathematics II',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: ColorTokens.onSurface,
              fontWeight: FontWeight.bold,
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
                  color: ColorTokens.primary.withValues(alpha: 0.15),
                  borderRadius: RadiusTokens.borderRadiusSm,
                ),
                child: Text(
                  'Theory',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: ColorTokens.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: SpacingTokens.md),
              const Icon(
                Symbols.schedule,
                size: 16,
                color: ColorTokens.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                '09:00 AM - 10:00 AM',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: ColorTokens.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: SpacingTokens.md),
            child: Divider(color: ColorTokens.outlineVariant),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Symbols.meeting_room,
                    size: 18,
                    color: ColorTokens.onSurfaceVariant,
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Text(
                    'Room 402',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: ColorTokens.onSurface,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Symbols.person,
                    size: 18,
                    color: ColorTokens.onSurfaceVariant,
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Text(
                    'Dr. A. Sharma',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: ColorTokens.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          Row(
            children: [
              const Icon(
                Symbols.calendar_today,
                size: 18,
                color: ColorTokens.onSurfaceVariant,
              ),
              const SizedBox(width: SpacingTokens.sm),
              Text(
                'Mon, Sep 15, 2025',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: ColorTokens.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryStatusSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attendance Status',
          style: theme.textTheme.titleMedium?.copyWith(
            color: ColorTokens.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SpacingTokens.md),
        Row(
          children: [
            Expanded(
              child: _PrimaryStatusCard(
                title: 'Present',
                description: 'You attended this lecture.',
                icon: Symbols.check_circle,
                color: SemanticColorTokens.present,
                isSelected: _primaryStatus == PrimaryStatus.present,
                onTap: () => _selectPrimaryStatus(PrimaryStatus.present),
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: _PrimaryStatusCard(
                title: 'Absent',
                description: 'You missed this lecture.',
                icon: Symbols.cancel,
                color: SemanticColorTokens.absent,
                isSelected: _primaryStatus == PrimaryStatus.absent,
                onTap: () => _selectPrimaryStatus(PrimaryStatus.absent),
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: _PrimaryStatusCard(
                title: 'Cancelled',
                description: 'This lecture did not take place.',
                icon: Symbols.block,
                color: SemanticColorTokens.cancelled,
                isSelected: _primaryStatus == PrimaryStatus.cancelled,
                onTap: () => _selectPrimaryStatus(PrimaryStatus.cancelled),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecondaryStatusSection(ThemeData theme) {
    final available = _availableSecondaryStatuses;

    return AnimatedSize(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      child: available.isEmpty
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.only(top: SpacingTokens.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Context (Optional)',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: ColorTokens.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  Wrap(
                    spacing: SpacingTokens.sm,
                    runSpacing: SpacingTokens.sm,
                    children: available.map((status) {
                      final isSelected = _secondaryStatus == status;
                      return FilterChip(
                        label: Text(status.label),
                        selected: isSelected,
                        onSelected: (selected) {
                          _selectSecondaryStatus(
                            selected ? status : _secondaryStatus!,
                          );
                          if (!selected) {
                            setState(() {
                              _secondaryStatus = null;
                            });
                          }
                        },
                        backgroundColor: ColorTokens.surfaceContainerHighest,
                        selectedColor: ColorTokens.primary.withValues(
                          alpha: 0.2,
                        ),
                        checkmarkColor: ColorTokens.primary,
                        labelStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? ColorTokens.primary
                              : ColorTokens.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : null,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? ColorTokens.primary.withValues(alpha: 0.5)
                              : Colors.transparent,
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: RadiusTokens.borderRadiusLg,
                        ),
                      );
                    }).toList(),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    child: _secondaryStatus == SecondaryStatus.other
                        ? Padding(
                            padding: const EdgeInsets.only(
                              top: SpacingTokens.md,
                            ),
                            child: TextField(
                              controller: _otherReasonController,
                              focusNode: _otherFocusNode,
                              style: const TextStyle(
                                color: ColorTokens.onSurface,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'What happened?',
                                hintStyle: TextStyle(
                                  color: ColorTokens.onSurfaceVariant,
                                ),
                                filled: true,
                                fillColor: ColorTokens.surfaceContainerHighest,
                                border: OutlineInputBorder(
                                  borderRadius: RadiusTokens.borderRadiusMd,
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.all(
                                  SpacingTokens.md,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildOptionalNote(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Note (Optional)',
          style: theme.textTheme.titleMedium?.copyWith(
            color: ColorTokens.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        TextField(
          controller: _noteController,
          maxLines: 4,
          minLines: 3,
          style: const TextStyle(color: ColorTokens.onSurface),
          decoration: const InputDecoration(
            hintText: 'Anything worth remembering about today\'s lecture?',
            hintStyle: TextStyle(color: ColorTokens.onSurfaceVariant),
            filled: true,
            fillColor: ColorTokens.surfaceContainerHigh,
            border: OutlineInputBorder(
              borderRadius: RadiusTokens.borderRadiusLg,
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: RadiusTokens.borderRadiusLg,
              borderSide: BorderSide(color: ColorTokens.primary, width: 2),
            ),
            contentPadding: EdgeInsets.all(SpacingTokens.lg),
          ),
        ),
      ],
    );
  }

  Widget _buildEvidenceSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Evidence (Optional)',
          style: theme.textTheme.titleMedium?.copyWith(
            color: ColorTokens.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          'Capture a classroom photo as a personal reference for this lecture.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: ColorTokens.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: SpacingTokens.md),

        // Compact indicators
        Row(
          children: [
            _buildIndicator(theme, Symbols.photo_camera, 'Camera only'),
            const SizedBox(width: SpacingTokens.md),
            _buildIndicator(theme, Symbols.sd_card, 'Stored locally'),
            const SizedBox(width: SpacingTokens.md),
            _buildIndicator(theme, Symbols.cloud_off, 'Never synced'),
          ],
        ),
        const SizedBox(height: SpacingTokens.lg),

        // Future-ready placeholder card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xxl),
          decoration: BoxDecoration(
            color: ColorTokens.surfaceContainerHigh,
            borderRadius: RadiusTokens.borderRadiusXl,
            border: Border.all(
              color: ColorTokens.outlineVariant,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(SpacingTokens.lg),
                decoration: const BoxDecoration(
                  color: ColorTokens.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Symbols.add_a_photo,
                  size: 32,
                  color: ColorTokens.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: SpacingTokens.lg),
              FilledButton.tonal(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Camera support will be available in a future update.',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: ColorTokens.surfaceContainerHighest,
                  foregroundColor: ColorTokens.onSurface,
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.xl,
                    vertical: SpacingTokens.md,
                  ),
                ),
                child: const Text('Take Photo'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIndicator(ThemeData theme, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: ColorTokens.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.labelSmall?.copyWith(
            color: ColorTokens.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStickySaveBar(ThemeData theme) {
    return Container(
      padding: EdgeInsets.only(
        left: LayoutTokens.screenPadding,
        right: LayoutTokens.screenPadding,
        top: SpacingTokens.md,
        bottom: MediaQuery.of(context).padding.bottom + SpacingTokens.md,
      ),
      decoration: BoxDecoration(
        color: ColorTokens.surface,
        border: const Border(
          top: BorderSide(color: ColorTokens.outlineVariant),
        ),
        boxShadow: [
          BoxShadow(
            color: ColorTokens.background.withValues(alpha: 0.8),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Once saved, this Lecture Record becomes a permanent part of your semester history.',
            style: theme.textTheme.labelSmall?.copyWith(
              color: ColorTokens.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SpacingTokens.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _primaryStatus == null
                  ? null
                  : () async {
                      final repo = ref.read(attendanceRepositoryProvider);
                      final now = DateTime.now().toUtc();
                      
                      await repo.create(AttendanceCompanion(
                        id: drift.Value(const Uuid().v4()),
                        userId: const drift.Value('mock_user_123'), // TODO: Real user
                        subjectId: const drift.Value('mock_subject_123'), // TODO: Pass from route
                        date: drift.Value(now.toIso8601String().split('T')[0]),
                        primaryStatus: drift.Value(_primaryStatus!.name),
                        secondaryStatus: drift.Value(_secondaryStatus?.name),
                        lectureType: const drift.Value('theory'),
                        notes: drift.Value(_noteController.text.isNotEmpty ? _noteController.text : null),
                        createdAt: drift.Value(now.toIso8601String()),
                        updatedAt: drift.Value(now.toIso8601String()),
                      ));

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Lecture Record saved.')),
                        );
                        context.pop();
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: ColorTokens.primary,
                foregroundColor: ColorTokens.onPrimary,
                disabledBackgroundColor: ColorTokens.surfaceContainerHighest,
                disabledForegroundColor: ColorTokens.onSurfaceVariant,
                padding: const EdgeInsets.symmetric(vertical: SpacingTokens.lg),
                shape: const RoundedRectangleBorder(
                  borderRadius: RadiusTokens.borderRadiusLg,
                ),
              ),
              child: const Text(
                'Save Lecture Record',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryStatusCard extends StatelessWidget {
  const _PrimaryStatusCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(SpacingTokens.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : ColorTokens.surfaceContainerHigh,
          borderRadius: RadiusTokens.borderRadiusLg,
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    isSelected ? Symbols.check_circle : icon,
                    key: ValueKey(isSelected),
                    color: isSelected ? color : ColorTokens.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                const SizedBox(width: SpacingTokens.xs),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isSelected ? color : ColorTokens.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.xs),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? ColorTokens.onSurface
                    : ColorTokens.onSurfaceVariant,
                fontSize: 10,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
