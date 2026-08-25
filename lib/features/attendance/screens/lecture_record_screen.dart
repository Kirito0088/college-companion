import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/attendance/providers/attendance_provider.dart';
import 'package:college_companion/features/attendance/repositories/lecture_record_repository.dart';
import 'package:college_companion/features/attendance/widgets/evidence_thumbnail_strip.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/subjects/providers/subject_detail_provider.dart';
import 'package:college_companion/features/timetable/models/lecture_schedule_item.dart';
import 'package:college_companion/features/timetable/providers/timetable_provider.dart';
import 'package:college_companion/shared/app_metadata.dart' as app_metadata;
import 'package:college_companion/shared/models/lecture_status.dart';
import 'package:college_companion/shared/widgets/cc_empty_state.dart';
import 'package:college_companion/shared/widgets/errors/cc_errors.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:uuid/uuid.dart';

enum PrimaryStatus { present, absent, cancelled }

enum SecondaryStatus {
  facultyAbsent('Faculty Absent', 'faculty_absent'),
  holiday('Holiday', 'holiday'),
  practicalCancelled('Practical Cancelled', 'practical_cancelled'),
  extraLecture('Extra Lecture', 'extra_lecture'),
  other('Other', 'other');

  const SecondaryStatus(this.label, this.wireKey);

  /// Display label shown in the UI.
  final String label;

  /// Key persisted in `lecture_records.status_text` (see
  /// [LectureStatus] — must stay in sync with its documented vocabulary).
  final String wireKey;

  /// Resolves the enum value for a wire key decoded from storage, if any.
  static SecondaryStatus? fromWireKey(String? key) {
    if (key == null) return null;
    for (final value in SecondaryStatus.values) {
      if (value.wireKey == key) return value;
    }
    return null;
  }
}

class LectureRecordScreen extends ConsumerStatefulWidget {
  const LectureRecordScreen({super.key, required this.timetableId});

  /// The timetable slot this record is for — identifies which lecture is
  /// being recorded (spec §3: 1:1 with `lecture_records.timetable_id`).
  final String timetableId;

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
  bool _saving = false;

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

  LectureStatus _buildStatus() {
    // `LectureStatus.encode()` joins fields with `|` (see
    // lecture_status.dart) — a `|` in free text would corrupt the decode
    // of this immutable, unfixable-after-the-fact record.
    final otherText = _secondaryStatus == SecondaryStatus.other
        ? _otherReasonController.text.trim().replaceAll('|', '/')
        : null;

    switch (_primaryStatus!) {
      case PrimaryStatus.present:
        return _secondaryStatus == SecondaryStatus.other
            ? LectureStatus.presentWithOther(otherText)
            : const LectureStatus.present();
      case PrimaryStatus.absent:
        return _secondaryStatus != null
            ? LectureStatus.absentWith(_secondaryStatus!.wireKey, otherText)
            : const LectureStatus.absent();
      case PrimaryStatus.cancelled:
        return _secondaryStatus != null
            ? LectureStatus.cancelledWith(_secondaryStatus!.wireKey, otherText)
            : const LectureStatus.cancelled();
    }
  }

  Future<void> _save({
    required String userId,
    required TimetableEntryEntity timetableEntry,
    required SubjectEntity subject,
  }) async {
    setState(() => _saving = true);
    final repo = ref.read(lectureRecordRepositoryProvider);

    try {
      await repo.create(
        id: _recordId,
        userId: userId,
        timetableId: widget.timetableId,
        subjectId: timetableEntry.subjectId,
        semesterId: subject.semesterId,
        status: _buildStatus(),
        note: _noteController.text.trim().isNotEmpty
            ? _noteController.text.trim()
            : null,
        deviceTimezone: app_metadata.currentDeviceTimezone(),
        appVersion: app_metadata.appVersion,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lecture Record saved.')));
      context.pop();
    } on LectureRecordExistsException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This lecture already has a record.')),
      );
      context.pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save this record. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;
    final authState = ref.watch(authStateProvider);
    final userId = authState is AuthAuthenticated ? authState.user.uid : '';

    final timetableAsync = ref.watch(
      timetableEntryByIdProvider(widget.timetableId),
    );

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
      body: timetableAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => NetworkErrorWidget(
          onRetry: () =>
              ref.invalidate(timetableEntryByIdProvider(widget.timetableId)),
        ),
        data: (timetableEntry) {
          if (userId.isEmpty) {
            return const CcEmptyState(
              icon: Symbols.lock_person,
              title: 'Sign in required',
              subtitle: 'Sign in to record this lecture.',
            );
          }
          if (timetableEntry == null) {
            return const CcEmptyState(
              icon: Symbols.event_busy,
              title: 'Lecture slot not found',
              subtitle: 'This class may have been removed from your timetable.',
            );
          }
          return _buildForTimetableEntry(
            context,
            theme,
            cc,
            userId,
            timetableEntry,
          );
        },
      ),
    );
  }

  /// Watches the subject and any existing record in parallel — both depend
  /// only on [timetableEntry]/[userId], not on each other, so there is no
  /// reason to resolve them sequentially.
  Widget _buildForTimetableEntry(
    BuildContext context,
    ThemeData theme,
    CCTokens cc,
    String userId,
    TimetableEntryEntity timetableEntry,
  ) {
    final subjectParams = (userId: userId, subjectId: timetableEntry.subjectId);
    final recordParams = (userId: userId, timetableId: widget.timetableId);

    final subjectAsync = ref.watch(subjectByIdStreamProvider(subjectParams));
    final existingRecordAsync = ref.watch(
      lectureRecordByTimetableIdProvider(recordParams),
    );

    if (subjectAsync.isLoading || existingRecordAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (subjectAsync.hasError) {
      return NetworkErrorWidget(
        onRetry: () => ref.invalidate(subjectByIdStreamProvider(subjectParams)),
      );
    }
    if (existingRecordAsync.hasError) {
      return NetworkErrorWidget(
        onRetry: () =>
            ref.invalidate(lectureRecordByTimetableIdProvider(recordParams)),
      );
    }

    final subject = subjectAsync.value;
    if (subject == null) {
      return const CcEmptyState(
        icon: Symbols.event_busy,
        title: 'Subject not found',
        subtitle: 'This lecture\'s subject may have been removed.',
      );
    }

    final existingRecord = existingRecordAsync.value;
    if (existingRecord != null) {
      return _buildLockedView(
        theme,
        cc,
        timetableEntry,
        subject,
        existingRecord,
      );
    }
    return _buildForm(context, theme, cc, userId, timetableEntry, subject);
  }

  // ── Scenario 2: locked, read-only ledger view ──────────────────────────

  Widget _buildLockedView(
    ThemeData theme,
    CCTokens cc,
    TimetableEntryEntity timetableEntry,
    SubjectEntity subject,
    LectureRecordEntity record,
  ) {
    final status = LectureStatus.decode(record.statusText);
    final secondary = SecondaryStatus.fromWireKey(status.secondary);
    final recordedLocal = record.recordedAt.toLocal();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: LayoutTokens.screenPadding,
        vertical: SpacingTokens.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(SpacingTokens.lg),
                  decoration: BoxDecoration(
                    color: cc.raise2,
                    shape: BoxShape.circle,
                    border: Border.all(color: cc.line, width: 1),
                  ),
                  child: Icon(Symbols.lock, size: 32, color: cc.pri),
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
          ),
          const SizedBox(height: SpacingTokens.xxl),
          _buildLectureInformation(theme, cc, timetableEntry, subject),
          const SizedBox(height: SpacingTokens.xxl),
          Container(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            decoration: BoxDecoration(
              color: cc.raise,
              borderRadius: RadiusTokens.borderRadiusXxl,
              border: Border.all(color: cc.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Symbols.lock, size: 16, color: cc.mut),
                    const SizedBox(width: SpacingTokens.xs),
                    Expanded(
                      child: Text(
                        'This record is permanent and cannot be edited.',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cc.mut,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SpacingTokens.md),
                _StatusPill(
                  primary: status.primary,
                  secondaryLabel: secondary?.label,
                  otherText: status.secondary == 'other'
                      ? status.otherText
                      : null,
                  cc: cc,
                  theme: theme,
                ),
                if (record.note != null && record.note!.isNotEmpty) ...[
                  const SizedBox(height: SpacingTokens.md),
                  Text(
                    'Note',
                    style: theme.textTheme.labelSmall?.copyWith(color: cc.mut),
                  ),
                  const SizedBox(height: SpacingTokens.xxs),
                  Text(
                    record.note!,
                    style: theme.textTheme.bodyMedium?.copyWith(color: cc.fg),
                  ),
                ],
                const SizedBox(height: SpacingTokens.md),
                Divider(color: cc.line),
                const SizedBox(height: SpacingTokens.md),
                Row(
                  children: [
                    Icon(Symbols.history_toggle_off, size: 16, color: cc.mut),
                    const SizedBox(width: SpacingTokens.xs),
                    Text(
                      'Recorded ${DateFormat('MMM d, yyyy • h:mm a').format(recordedLocal)}',
                      style: theme.textTheme.bodySmall?.copyWith(color: cc.mut),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.xxl),
          Text(
            'Evidence',
            style: theme.textTheme.titleMedium?.copyWith(
              color: cc.fg,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          EvidenceThumbnailStrip(recordId: record.id, readOnly: true),
          const SizedBox(height: SpacingTokens.xxl),
        ],
      ),
    );
  }

  // ── Scenario 1: create form ─────────────────────────────────────────

  Widget _buildForm(
    BuildContext context,
    ThemeData theme,
    CCTokens cc,
    String userId,
    TimetableEntryEntity timetableEntry,
    SubjectEntity subject,
  ) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Stack(
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
                _buildLectureInformation(theme, cc, timetableEntry, subject),
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
          child: _buildStickySaveBar(
            theme,
            cc,
            userId,
            timetableEntry,
            subject,
          ),
        ),
      ],
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

  Widget _buildLectureInformation(
    ThemeData theme,
    CCTokens cc,
    TimetableEntryEntity timetableEntry,
    SubjectEntity subject,
  ) {
    final lectureType = timetableEntry.lectureType.isNotEmpty
        ? timetableEntry.lectureType[0].toUpperCase() +
              timetableEntry.lectureType.substring(1)
        : 'Theory';

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
            subject.name,
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
                  lectureType,
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
                '${LectureScheduleItem.formatTimeSlot(timetableEntry.startTime)} - ${LectureScheduleItem.formatTimeSlot(timetableEntry.endTime)}',
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
                    timetableEntry.room?.isNotEmpty == true
                        ? timetableEntry.room!
                        : 'No room set',
                    style: theme.textTheme.bodyMedium?.copyWith(color: cc.fg),
                  ),
                ],
              ),
              if (subject.faculty != null && subject.faculty!.isNotEmpty)
                Row(
                  children: [
                    Icon(Symbols.person, size: 18, color: cc.mut),
                    const SizedBox(width: SpacingTokens.sm),
                    Text(
                      subject.faculty!,
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
                DateFormat('EEE, MMM d, yyyy').format(DateTime.now()),
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
        Wrap(
          spacing: SpacingTokens.md,
          runSpacing: SpacingTokens.xs,
          children: [
            _buildIndicator(theme, cc, Symbols.photo_camera, 'Camera only'),
            _buildIndicator(theme, cc, Symbols.sd_card, 'Stored locally'),
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

  Widget _buildStickySaveBar(
    ThemeData theme,
    CCTokens cc,
    String userId,
    TimetableEntryEntity timetableEntry,
    SubjectEntity subject,
  ) {
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
              onPressed: _primaryStatus == null || _saving
                  ? null
                  : () => _save(
                      userId: userId,
                      timetableEntry: timetableEntry,
                      subject: subject,
                    ),
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
              child: _saving
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cc.priFg,
                      ),
                    )
                  : const Text(
                      'Save Lecture Record',
                      style: TextStyle(
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.primary,
    required this.secondaryLabel,
    required this.otherText,
    required this.cc,
    required this.theme,
  });

  final String primary;
  final String? secondaryLabel;
  final String? otherText;
  final CCTokens cc;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    final IconData icon;
    switch (primary) {
      case 'present':
        color = cc.pri;
        label = 'Present';
        icon = Symbols.check_circle;
      case 'cancelled':
        color = cc.warn;
        label = 'Cancelled';
        icon = Symbols.block;
      default:
        color = cc.risk;
        label = 'Absent';
        icon = Symbols.cancel;
    }

    final detail = otherText != null && otherText!.isNotEmpty
        ? otherText
        : secondaryLabel;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.sm,
            vertical: SpacingTokens.xxs,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: RadiusTokens.borderRadiusPill,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: SpacingTokens.xs),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (detail != null) ...[
          const SizedBox(width: SpacingTokens.sm),
          Flexible(
            child: Text(
              detail,
              style: theme.textTheme.bodyMedium?.copyWith(color: cc.mut),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}
