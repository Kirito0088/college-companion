/// Evidence Thumbnail Strip
///
/// Horizontally scrolling strip of photo thumbnails with micro-borders,
/// lightbox preview trigger on tap, and add photo action tile.
library;

import 'dart:typed_data';

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/attendance/providers/attendance_evidence_provider.dart';
import 'package:college_companion/features/attendance/widgets/evidence_capture_sheet.dart';
import 'package:college_companion/features/attendance/widgets/evidence_preview_dialog.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Horizontal strip displaying evidence thumbnails with tap-to-preview lightbox.
class EvidenceThumbnailStrip extends ConsumerWidget {
  const EvidenceThumbnailStrip({
    super.key,
    required this.recordId,
    this.readOnly = false,
  });

  final String recordId;

  /// When true, evidence can be viewed but not captured or deleted — used
  /// for an already-recorded (locked) lecture record.
  final bool readOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final evidenceAsync = ref.watch(attendanceEvidenceProvider(recordId));

    return evidenceAsync.when(
      data: (evidenceList) {
        if (evidenceList.isEmpty) {
          return readOnly
              ? _buildReadOnlyEmptyState(context)
              : _buildEmptyState(context);
        }
        return _buildStrip(context, evidenceList);
      },
      loading: () => SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator(color: colors.primary)),
      ),
      error: (e, _) => Container(
        height: 80,
        padding: const EdgeInsets.all(SpacingTokens.md),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: RadiusTokens.borderRadiusLg,
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(Symbols.error, color: colors.error, size: 20),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Text(
                'Failed to load evidence: $e',
                style: TextStyle(color: colors.error, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      onTap: () => EvidenceCaptureSheet.show(context, recordId: recordId),
      borderRadius: RadiusTokens.borderRadiusLg,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.lg,
          vertical: SpacingTokens.base,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: RadiusTokens.borderRadiusLg,
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(SpacingTokens.sm),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Symbols.add_a_photo,
                size: 20,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: SpacingTokens.md),
            Text(
              'Add Evidence',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.lg,
        vertical: SpacingTokens.base,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: RadiusTokens.borderRadiusLg,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Text(
        'No evidence was captured for this record.',
        style: theme.textTheme.labelLarge?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildStrip(
    BuildContext context,
    List<LectureEvidenceEntity> evidenceList,
  ) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: readOnly ? evidenceList.length : evidenceList.length + 1,
        separatorBuilder: (context, index) =>
            const SizedBox(width: SpacingTokens.sm),
        itemBuilder: (context, index) {
          if (!readOnly && index == evidenceList.length) {
            // Add more photo tile
            return _buildAddTile(context);
          }

          final item = evidenceList[index];
          return EvidenceThumbnailCard(
            evidence: item,
            recordId: recordId,
            readOnly: readOnly,
          );
        },
      ),
    );
  }

  Widget _buildAddTile(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => EvidenceCaptureSheet.show(context, recordId: recordId),
      borderRadius: RadiusTokens.borderRadiusLg,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: RadiusTokens.borderRadiusLg,
          border: Border.all(
            color: colors.outlineVariant,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Icon(Symbols.add, color: colors.onSurfaceVariant, size: 24),
        ),
      ),
    );
  }
}

/// Single square thumbnail tile with cached image preview and tap-to-preview trigger.
class EvidenceThumbnailCard extends ConsumerStatefulWidget {
  const EvidenceThumbnailCard({
    super.key,
    required this.evidence,
    required this.recordId,
    this.readOnly = false,
  });

  final LectureEvidenceEntity evidence;
  final String recordId;
  final bool readOnly;

  @override
  ConsumerState<EvidenceThumbnailCard> createState() =>
      _EvidenceThumbnailCardState();
}

class _EvidenceThumbnailCardState extends ConsumerState<EvidenceThumbnailCard> {
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final storage = ref.read(imageStorageServiceProvider);
    final bytes = await storage.readBytes(widget.evidence.localPathRelative);
    if (mounted) {
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {
        EvidencePreviewDialog.show(
          context,
          evidence: widget.evidence,
          recordId: widget.recordId,
          readOnly: widget.readOnly,
        );
      },
      borderRadius: RadiusTokens.borderRadiusLg,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: RadiusTokens.borderRadiusLg,
          border: Border.all(color: colors.outlineVariant, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: _imageBytes != null
            ? Image.memory(
                _imageBytes!,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Symbols.broken_image,
                      size: 24,
                      color: colors.onSurfaceVariant,
                    ),
                  );
                },
              )
            : Center(
                child: Icon(
                  Symbols.image,
                  size: 24,
                  color: colors.onSurfaceVariant,
                ),
              ),
      ),
    );
  }
}
