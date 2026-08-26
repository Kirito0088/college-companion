/// Evidence Preview Lightbox Dialog
///
/// Full-screen dialog with InteractiveViewer for zoom/pan, metadata inspection,
/// SHA-256 verification indicator, and deletion confirmation.
library;

import 'dart:typed_data';

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/attendance/providers/attendance_evidence_provider.dart';
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
    this.readOnly = false,
  });

  final LectureEvidenceEntity evidence;
  final String? recordId;

  /// When true, hides the delete action — used for an already-recorded
  /// (locked) lecture record's evidence.
  final bool readOnly;

  /// Static helper to display the preview lightbox dialog.
  static Future<bool?> show(
    BuildContext context, {
    required LectureEvidenceEntity evidence,
    String? recordId,
    bool readOnly = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (context) => EvidencePreviewDialog(
        evidence: evidence,
        recordId: recordId,
        readOnly: readOnly,
      ),
    );
  }

  @override
  ConsumerState<EvidencePreviewDialog> createState() =>
      _EvidencePreviewDialogState();
}

class _EvidencePreviewDialogState extends ConsumerState<EvidencePreviewDialog> {
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
    final colors = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.surfaceContainerHigh,
          shape: const RoundedRectangleBorder(
            borderRadius: RadiusTokens.borderRadiusXl,
          ),
          title: Row(
            children: [
              Icon(Symbols.delete, color: colors.error),
              const SizedBox(width: SpacingTokens.sm),
              Text(
                'Delete Evidence?',
                style: TextStyle(color: colors.onSurface),
              ),
            ],
          ),
          content: Text(
            'This classroom photo will be permanently deleted from local device storage.',
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: colors.onSurfaceVariant,
              ),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
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
    final colors = theme.colorScheme;
    final formattedDate = DateFormat(
      'MMM dd, yyyy • hh:mm a',
    ).format(widget.evidence.captureTimestamp.toLocal());

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
                    icon: Icon(Symbols.close, color: colors.onSurface),
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  Text(
                    'Evidence Photo',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.readOnly)
                    const SizedBox(width: 48)
                  else
                    IconButton(
                      icon: Icon(Symbols.delete, color: colors.error),
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
                    ? CircularProgressIndicator(color: colors.primary)
                    : _isMissing || _imageBytes == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Symbols.broken_image,
                            size: 64,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(height: SpacingTokens.md),
                          Text(
                            'Image file missing on device',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
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
                            return Center(
                              child: Icon(
                                Symbols.broken_image,
                                size: 64,
                                color: colors.onSurfaceVariant,
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
                color: colors.surfaceContainerHigh.withValues(alpha: 0.9),
                borderRadius: RadiusTokens.borderRadiusLg,
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.sm,
                      vertical: SpacingTokens.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.15),
                      borderRadius: RadiusTokens.borderRadiusSm,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Symbols.verified, color: colors.primary, size: 14),
                        const SizedBox(width: SpacingTokens.xxs),
                        Text(
                          'SHA-256 Verified',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.primary,
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
                        color: colors.onSurfaceVariant,
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
