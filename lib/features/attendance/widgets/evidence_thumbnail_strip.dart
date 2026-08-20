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
import 'package:college_companion/theme/color_tokens.dart';
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
  });

  final String recordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final evidenceAsync = ref.watch(attendanceEvidenceProvider(recordId));

    return evidenceAsync.when(
      data: (evidenceList) {
        if (evidenceList.isEmpty) {
          return _buildEmptyState(context);
        }
        return _buildStrip(context, evidenceList);
      },
      loading: () => const SizedBox(
        height: 80,
        child: Center(
          child: CircularProgressIndicator(color: ColorTokens.primary),
        ),
      ),
      error: (e, _) => Container(
        height: 80,
        padding: const EdgeInsets.all(SpacingTokens.md),
        decoration: BoxDecoration(
          color: ColorTokens.surfaceContainerHigh,
          borderRadius: RadiusTokens.borderRadiusLg,
          border: Border.all(color: ColorTokens.outlineVariant),
        ),
        child: Row(
          children: [
            const Icon(Symbols.error, color: ColorTokens.error, size: 20),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Text(
                'Failed to load evidence: $e',
                style: const TextStyle(
                  color: ColorTokens.error,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => EvidenceCaptureSheet.show(context, recordId: recordId),
      borderRadius: RadiusTokens.borderRadiusLg,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.lg,
          vertical: SpacingTokens.base,
        ),
        decoration: BoxDecoration(
          color: ColorTokens.surfaceContainerHigh,
          borderRadius: RadiusTokens.borderRadiusLg,
          border: Border.all(color: ColorTokens.outlineVariant),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(SpacingTokens.sm),
              decoration: const BoxDecoration(
                color: ColorTokens.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Symbols.add_a_photo,
                size: 20,
                color: ColorTokens.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: SpacingTokens.md),
            Text(
              'Add Evidence',
              style: theme.textTheme.labelLarge?.copyWith(
                color: ColorTokens.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
        itemCount: evidenceList.length + 1,
        separatorBuilder: (context, index) =>
            const SizedBox(width: SpacingTokens.sm),
        itemBuilder: (context, index) {
          if (index == evidenceList.length) {
            // Add more photo tile
            return _buildAddTile(context);
          }

          final item = evidenceList[index];
          return EvidenceThumbnailCard(
            evidence: item,
            recordId: recordId,
          );
        },
      ),
    );
  }

  Widget _buildAddTile(BuildContext context) {
    return InkWell(
      onTap: () => EvidenceCaptureSheet.show(context, recordId: recordId),
      borderRadius: RadiusTokens.borderRadiusLg,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: ColorTokens.surfaceContainerHigh,
          borderRadius: RadiusTokens.borderRadiusLg,
          border: Border.all(
            color: ColorTokens.outlineVariant,
            style: BorderStyle.solid,
          ),
        ),
        child: const Center(
          child: Icon(
            Symbols.add,
            color: ColorTokens.onSurfaceVariant,
            size: 24,
          ),
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
  });

  final LectureEvidenceEntity evidence;
  final String recordId;

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
    return InkWell(
      onTap: () {
        EvidencePreviewDialog.show(
          context,
          evidence: widget.evidence,
          recordId: widget.recordId,
        );
      },
      borderRadius: RadiusTokens.borderRadiusLg,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: ColorTokens.surfaceContainerHighest,
          borderRadius: RadiusTokens.borderRadiusLg,
          border: Border.all(color: ColorTokens.outlineVariant, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: _imageBytes != null
            ? Image.memory(
                _imageBytes!,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Symbols.broken_image,
                      size: 24,
                      color: ColorTokens.onSurfaceVariant,
                    ),
                  );
                },
              )
            : const Center(
                child: Icon(
                  Symbols.image,
                  size: 24,
                  color: ColorTokens.onSurfaceVariant,
                ),
              ),
      ),
    );
  }
}
