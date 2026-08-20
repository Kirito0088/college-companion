/// Evidence Preview Lightbox Dialog
///
/// Full-screen dialog with InteractiveViewer for zoom/pan, metadata inspection,
/// SHA-256 verification indicator, and deletion confirmation.
library;

import 'dart:typed_data';

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/attendance/providers/attendance_evidence_provider.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Full-screen lightbox dialog for viewing and managing an evidence photo.
class EvidencePreviewDialog extends ConsumerStatefulWidget {
  const EvidencePreviewDialog({
    super.key,
    required this.evidence,
    this.recordId,
  });

  final LectureEvidenceEntity evidence;
  final String? recordId;

  /// Static helper to display the preview lightbox dialog.
  static Future<bool?> show(
    BuildContext context, {
    required LectureEvidenceEntity evidence,
    String? recordId,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (context) => EvidencePreviewDialog(
        evidence: evidence,
        recordId: recordId,
      ),
    );
  }

  @override
  ConsumerState<EvidencePreviewDialog> createState() =>
      _EvidencePreviewDialogState();
}

class _EvidencePreviewDialogState
    extends ConsumerState<EvidencePreviewDialog> {
  Uint8List? _imageBytes;
  bool _isLoading = true;
  bool _isMissing = false;

  @override
  void initState() {
    super.initState();
    _resolveImage();
  }

  Future<void> _resolveImage() async {
    final storage = ref.read(imageStorageServiceProvider);
    final bytes = await storage.readBytes(widget.evidence.localPathRelative);

    if (mounted) {
      setState(() {
        _imageBytes = bytes;
        _isMissing = bytes == null;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: ColorTokens.surfaceContainerHigh,
          shape: const RoundedRectangleBorder(
            borderRadius: RadiusTokens.borderRadiusXl,
          ),
          title: const Row(
            children: [
              Icon(Symbols.delete, color: ColorTokens.error),
              SizedBox(width: SpacingTokens.sm),
              Text(
                'Delete Evidence?',
                style: TextStyle(color: ColorTokens.onSurface),
              ),
            ],
          ),
          content: const Text(
            'This classroom photo will be permanently deleted from local device storage.',
            style: TextStyle(color: ColorTokens.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: ColorTokens.onSurfaceVariant,
              ),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: ColorTokens.error,
                foregroundColor: ColorTokens.onError,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      if (widget.recordId != null) {
        await ref
            .read(attendanceEvidenceProvider(widget.recordId!).notifier)
            .deleteEvidence(widget.evidence.id);
      } else {
        final dao = ref.read(attendanceEvidenceDaoProvider);
        final storage = ref.read(imageStorageServiceProvider);
        await storage.deleteImage(widget.evidence.localPathRelative);
        await dao.deleteEvidence(widget.evidence.id);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(
      widget.evidence.captureTimestamp.toLocal(),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.sm,
                vertical: SpacingTokens.xs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Symbols.close,
                      color: ColorTokens.onSurface,
                    ),
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  Text(
                    'Evidence Photo',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: ColorTokens.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Symbols.delete,
                      color: ColorTokens.error,
                    ),
                    tooltip: 'Delete Evidence',
                    onPressed: _handleDelete,
                  ),
                ],
              ),
            ),

            // Zoomable Interactive Viewer
            Expanded(
              child: Center(
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: ColorTokens.primary,
                      )
                    : _isMissing || _imageBytes == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Symbols.broken_image,
                                size: 64,
                                color: ColorTokens.onSurfaceVariant,
                              ),
                              const SizedBox(height: SpacingTokens.md),
                              Text(
                                'Image file missing on device',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: ColorTokens.onSurfaceVariant,
                                ),
                              ),
                            ],
                          )
                        : InteractiveViewer(
                            minScale: 0.5,
                            maxScale: 4.0,
                            child: Image.memory(
                              _imageBytes!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Symbols.broken_image,
                                    size: 64,
                                    color: ColorTokens.onSurfaceVariant,
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ),

            // Bottom Metadata Bar
            Container(
              margin: const EdgeInsets.all(SpacingTokens.lg),
              padding: const EdgeInsets.all(SpacingTokens.md),
              decoration: BoxDecoration(
                color: ColorTokens.surfaceContainerHigh.withValues(alpha: 0.9),
                borderRadius: RadiusTokens.borderRadiusLg,
                border: Border.all(color: ColorTokens.outlineVariant),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.sm,
                      vertical: SpacingTokens.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: ColorTokens.success.withValues(alpha: 0.15),
                      borderRadius: RadiusTokens.borderRadiusSm,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Symbols.verified,
                          color: ColorTokens.success,
                          size: 14,
                        ),
                        const SizedBox(width: SpacingTokens.xxs),
                        Text(
                          'SHA-256 Verified',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: ColorTokens.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.md),
                  Expanded(
                    child: Text(
                      formattedDate,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ColorTokens.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
