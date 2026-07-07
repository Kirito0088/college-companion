import 'package:college_companion/features/attendance/providers/attendance_provider.dart';
import 'package:college_companion/features/attendance/repositories/lecture_record_repository.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/shared/app_metadata.dart';
import 'package:college_companion/shared/models/lecture_status.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

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

/// Context passed into [LectureRecordScreen] via `route.extra`.
///
/// The IDs (`timetableId`, `subjectId`, `semesterId`) are required to create
/// an immutable [lecture_records] row; the display fields drive the lecture
/// info card at the top of the screen.
class LectureRecordArgs {
  const LectureRecordArgs({
    required this.timetableId,
    required this.subjectId,
    required this.semesterId,
    required this.subjectName,
    required this.typeLabel,
    required this.timeRange,
    required this.dateLabel,
    this.room,
    this.faculty,
  });

  final String timetableId;
  final String subjectId;
  final String semesterId;
  final String subjectName;
  final String typeLabel;
  final String timeRange;
  final String dateLabel;
  final String? room;
  final String? faculty;
}

class LectureRecordScreen extends ConsumerStatefulWidget {
  const LectureRecordScreen({super.key, this.args});

  final LectureRecordArgs? args;

  @override
  ConsumerState<LectureRecordScreen> createState() =>
      _LectureRecordScreenState();
}

class _LectureRecordScreenState extends ConsumerState<LectureRecordScreen> {
  PrimaryStatus? _primaryStatus;
  SecondaryStatus? _secondaryStatus;
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _otherReasonController = TextEditingController();
  final FocusNode _otherFocusNode = FocusNode();
  bool _saving = false;

  @override
  void dispose() {
    _noteController.dispose();
    _otherReasonController.dispose();
    _otherFocusNode.dispose();
    super.dispose();
  }

  /// Builds the immutable [LectureStatus] value object from the current
  /// UI selections. `null` until a primary status is chosen.
  LectureStatus? _buildLectureStatus() {
    final otherText = _otherReasonController.text.trim();
    switch (_primaryStatus) {
      case PrimaryStatus.present:
        return _secondaryStatus == SecondaryStatus.other
            ? LectureStatus.presentWithOther(otherText)
            : const LectureStatus.present();
      case PrimaryStatus.absent:
        switch (_secondaryStatus) {
          case SecondaryStatus.holiday:
            return const LectureStatus.absentWith('holiday');
          case SecondaryStatus.facultyAbsent:
            return const LectureStatus.absentWith('faculty_absent');
          case SecondaryStatus.other:
            return LectureStatus.absentWith('other', otherText);
          case SecondaryStatus.practicalCancelled:
          case SecondaryStatus.extraLecture:
          case null:
            return const LectureStatus.absent();
        }
      case PrimaryStatus.cancelled:
        switch (_secondaryStatus) {
          case SecondaryStatus.facultyAbsent:
            return const LectureStatus.cancelledWith('faculty_absent');
          case SecondaryStatus.practicalCancelled:
            return const LectureStatus.cancelledWith('practical_cancelled');
          case SecondaryStatus.extraLecture:
            return const LectureStatus.cancelledWith('extra_lecture');
          case SecondaryStatus.other:
            return LectureStatus.cancelledWith('other', otherText);
          case SecondaryStatus.holiday:
          case null:
            return const LectureStatus.cancelled();
        }
      case null:
        return null;
    }
  }

  /// Saves the immutable lecture record (Phase 4 wiring).
  ///
  /// Enforces 1:1 at the repository layer; surfaces a duplicate-slot
  /// conflict as a friendly SnackBar rather than popping. Non-duplicate
  /// failures are surfaced verbatim. Pops on success only.
  Future<void> _saveLectureRecord() async {
    final args = widget.args;
    if (args == null) {
      _showMessage('Lecture context unavailable. Open this from a lecture.');
      return;
    }

    final status = _buildLectureStatus();
    if (status == null) return; // Save button is disabled in this case.

    final authState = ref.read(authStateProvider);
    if (authState is! AuthAuthenticated) {
      _showMessage('Sign in to save a lecture record.');
      return;
    }

    final noteText = _noteController.text.trim();

    setState(() => _saving = true);
    try {
      final repo = ref.read(lectureRecordRepositoryProvider);
      await repo.create(
        userId: authState.user.uid,
        timetableId: args.timetableId,
        subjectId: args.subjectId,
        semesterId: args.semesterId,
        status: status,
        note: noteText.isEmpty ? null : noteText,
        deviceTimezone: currentDeviceTimezone(),
        appVersion: appVersion,
      );
      if (!mounted) return;
      _showMessage('Lecture record saved.');
      context.pop(true); // signal success to caller
    } on LectureRecordExistsException {
      if (!mounted) return;
      _showMessage('This lecture already has a record.');
    } on Exception catch (error) {
      if (!mounted) return;
      _showMessage('Could not save: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
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
    // Display values sourced from route args when available; the existing
    // mock strings remain as fallbacks so the screen still renders when
    // opened without args (e.g. during isolated development).
    final args = widget.args;
    final subjectName = args?.subjectName ?? 'Advanced Mathematics II';
    final typeLabel = args?.typeLabel ?? 'Theory';
    final timeRange = args?.timeRange ?? '09:00 AM - 10:00 AM';
    final room = args?.room ?? 'Room 402';
    final faculty = args?.faculty ?? 'Dr. A. Sharma';
    final dateLabel = args?.dateLabel ?? 'Mon, Sep 15, 2025';

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
            subjectName,
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
                  typeLabel,
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
                timeRange,
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
                    room,
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
                    faculty,
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
                dateLabel,
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
              onPressed: (_primaryStatus == null || _saving)
                  ? null
                  : _saveLectureRecord,
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
              child: Text(
                _saving ? 'Saving…' : 'Save Lecture Record',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
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
