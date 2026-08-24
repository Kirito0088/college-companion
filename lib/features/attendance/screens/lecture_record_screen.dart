import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/attendance/providers/attendance_provider.dart';
import 'package:college_companion/features/attendance/widgets/evidence_thumbnail_strip.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/theme/cc_tokens.dart';
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
  const LectureRecordScreen({super.key, this.subjectId});

  final String? subjectId;

  @override
  ConsumerState<LectureRecordScreen> createState() =>
      _LectureRecordScreenState();
}

class _LectureRecordScreenState extends ConsumerState<LectureRecordScreen> {
  late final String _recordId = const Uuid().v4();
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
    final cc = context.cc;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Symbols.close, color: cc.fg),
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
                  _buildHeroAnchor(theme, cc),
                  const SizedBox(height: SpacingTokens.xxl),
                  _buildLectureInformation(theme, cc),
                  const SizedBox(height: SpacingTokens.xxl),
                  _buildPrimaryStatusSection(theme, cc),
                  _buildSecondaryStatusSection(theme, cc),
                  const SizedBox(height: SpacingTokens.xxl),
                  _buildOptionalNote(theme, cc),
                  const SizedBox(height: SpacingTokens.xxl),
                  _buildEvidenceSection(theme, cc),
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
            child: _buildStickySaveBar(theme, cc),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroAnchor(ThemeData theme, CCTokens cc) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            decoration: BoxDecoration(
              color: cc.raise2,
              shape: BoxShape.circle,
              border: Border.all(color: cc.line, width: 1),
            ),
            child: Icon(Symbols.history_edu, size: 32, color: cc.pri),
          ),
          const SizedBox(height: SpacingTokens.md),
          Text(
            'Lecture Record',
            style: theme.textTheme.titleMedium?.copyWith(
              color: cc.mut,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLectureInformation(ThemeData theme, CCTokens cc) {
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        color: cc.raise,
        borderRadius: RadiusTokens.borderRadiusXxl,
        border: Border.all(color: cc.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advanced Mathematics II',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: cc.fg,
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
                  color: cc.priSoft,
                  borderRadius: RadiusTokens.borderRadiusSm,
                ),
                child: Text(
                  'Theory',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cc.pri,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: SpacingTokens.md),
              Icon(Symbols.schedule, size: 16, color: cc.mut),
              const SizedBox(width: 4),
              Text(
                '09:00 AM - 10:00 AM',
                style: theme.textTheme.bodyMedium?.copyWith(color: cc.mut),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
            child: Divider(color: cc.line),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Symbols.meeting_room, size: 18, color: cc.mut),
                  const SizedBox(width: SpacingTokens.sm),
                  Text(
                    'Room 402',
                    style: theme.textTheme.bodyMedium?.copyWith(color: cc.fg),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Symbols.person, size: 18, color: cc.mut),
                  const SizedBox(width: SpacingTokens.sm),
                  Text(
                    'Dr. A. Sharma',
                    style: theme.textTheme.bodyMedium?.copyWith(color: cc.fg),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          Row(
            children: [
              Icon(Symbols.calendar_today, size: 18, color: cc.mut),
              const SizedBox(width: SpacingTokens.sm),
              Text(
                'Mon, Sep 15, 2025',
                style: theme.textTheme.bodyMedium?.copyWith(color: cc.fg),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryStatusSection(ThemeData theme, CCTokens cc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attendance Status',
          style: theme.textTheme.titleMedium?.copyWith(
            color: cc.fg,
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
                color: cc.pri,
                mutedColor: cc.mut,
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
                color: cc.risk,
                mutedColor: cc.mut,
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
                color: cc.warn,
                mutedColor: cc.mut,
                isSelected: _primaryStatus == PrimaryStatus.cancelled,
                onTap: () => _selectPrimaryStatus(PrimaryStatus.cancelled),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecondaryStatusSection(ThemeData theme, CCTokens cc) {
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
                    style: theme.textTheme.titleSmall?.copyWith(color: cc.mut),
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
                        backgroundColor: cc.raise2,
                        selectedColor: cc.priSoft,
                        checkmarkColor: cc.pri,
                        labelStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: isSelected ? cc.pri : cc.fg,
                          fontWeight: isSelected ? FontWeight.bold : null,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? cc.pri.withValues(alpha: 0.5)
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
                              style: TextStyle(color: cc.fg),
                              decoration: InputDecoration(
                                hintText: 'What happened?',
                                hintStyle: TextStyle(color: cc.mut),
                                filled: true,
                                fillColor: cc.raise2,
                                border: const OutlineInputBorder(
                                  borderRadius: RadiusTokens.borderRadiusMd,
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.all(
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

  Widget _buildOptionalNote(ThemeData theme, CCTokens cc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Note (Optional)',
          style: theme.textTheme.titleMedium?.copyWith(
            color: cc.fg,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        TextField(
          controller: _noteController,
          maxLines: 4,
          minLines: 3,
          style: TextStyle(color: cc.fg),
          decoration: InputDecoration(
            hintText: 'Anything worth remembering about today\'s lecture?',
            hintStyle: TextStyle(color: cc.mut),
            filled: true,
            fillColor: cc.raise,
            border: const OutlineInputBorder(
              borderRadius: RadiusTokens.borderRadiusLg,
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: RadiusTokens.borderRadiusLg,
              borderSide: BorderSide(color: cc.pri, width: 2),
            ),
            contentPadding: const EdgeInsets.all(SpacingTokens.lg),
          ),
        ),
      ],
    );
  }

  Widget _buildEvidenceSection(ThemeData theme, CCTokens cc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Evidence (Optional)',
          style: theme.textTheme.titleMedium?.copyWith(
            color: cc.fg,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          'Capture a classroom photo as a personal reference for this lecture.',
          style: theme.textTheme.bodyMedium?.copyWith(color: cc.mut),
        ),
        const SizedBox(height: SpacingTokens.md),

        // Compact indicators
        Row(
          children: [
            _buildIndicator(theme, cc, Symbols.photo_camera, 'Camera only'),
            const SizedBox(width: SpacingTokens.md),
            _buildIndicator(theme, cc, Symbols.sd_card, 'Stored locally'),
            const SizedBox(width: SpacingTokens.md),
            _buildIndicator(theme, cc, Symbols.cloud_off, 'Never synced'),
          ],
        ),
        const SizedBox(height: SpacingTokens.lg),
        EvidenceThumbnailStrip(recordId: _recordId),
      ],
    );
  }

  Widget _buildIndicator(
    ThemeData theme,
    CCTokens cc,
    IconData icon,
    String text,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: cc.mut),
        const SizedBox(width: 4),
        Text(text, style: theme.textTheme.labelSmall?.copyWith(color: cc.mut)),
      ],
    );
  }

  Widget _buildStickySaveBar(ThemeData theme, CCTokens cc) {
    return Container(
      padding: EdgeInsets.only(
        left: LayoutTokens.screenPadding,
        right: LayoutTokens.screenPadding,
        top: SpacingTokens.md,
        bottom: MediaQuery.of(context).padding.bottom + SpacingTokens.md,
      ),
      decoration: BoxDecoration(
        color: cc.surf,
        border: Border(top: BorderSide(color: cc.line)),
        boxShadow: [
          BoxShadow(
            color: cc.bg.withValues(alpha: 0.8),
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
            style: theme.textTheme.labelSmall?.copyWith(color: cc.mut),
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

                      final authState = ref.read(authStateProvider);
                      final activeUserId =
                          authState is AuthAuthenticated &&
                              authState.user.uid.isNotEmpty
                          ? authState.user.uid
                          : 'default_user';

                      await repo.create(
                        AttendanceCompanion(
                          id: drift.Value(_recordId),
                          userId: drift.Value(activeUserId),
                          subjectId: drift.Value(
                            widget.subjectId ?? 'default_subject',
                          ),
                          date: drift.Value(
                            now.toIso8601String().split('T')[0],
                          ),
                          primaryStatus: drift.Value(_primaryStatus!.name),
                          secondaryStatus: drift.Value(_secondaryStatus?.name),
                          lectureType: const drift.Value('theory'),
                          notes: drift.Value(
                            _noteController.text.isNotEmpty
                                ? _noteController.text
                                : null,
                          ),
                          createdAt: drift.Value(now.toIso8601String()),
                          updatedAt: drift.Value(now.toIso8601String()),
                        ),
                      );

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Lecture Record saved.'),
                          ),
                        );
                        context.pop();
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: cc.pri,
                foregroundColor: cc.priFg,
                disabledBackgroundColor: cc.raise2,
                disabledForegroundColor: cc.mut,
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
    required this.mutedColor,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Color mutedColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(SpacingTokens.sm),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : cc.raise2,
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
                    color: isSelected ? color : mutedColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: SpacingTokens.xs),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isSelected ? color : cc.fg,
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
                color: isSelected ? cc.fg : mutedColor,
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
