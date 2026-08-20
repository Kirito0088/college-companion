/// Evidence Capture Bottom Sheet
///
/// Modal bottom sheet allowing users to capture classroom photos via camera
/// or choose from gallery with optional note attachment.
library;

import 'package:college_companion/features/attendance/providers/attendance_evidence_provider.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Modal sheet for capturing or selecting evidence photos.
class EvidenceCaptureSheet extends ConsumerStatefulWidget {
  const EvidenceCaptureSheet({
    super.key,
    required this.recordId,
    this.onSourceSelected,
  });

  final String recordId;
  final void Function(ImageSource source, String? note)? onSourceSelected;

  /// Helper to display this modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required String recordId,
    void Function(ImageSource source, String? note)? onSourceSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EvidenceCaptureSheet(
        recordId: recordId,
        onSourceSelected: onSourceSelected,
      ),
    );
  }

  @override
  ConsumerState<EvidenceCaptureSheet> createState() =>
      _EvidenceCaptureSheetState();
}

class _EvidenceCaptureSheetState extends ConsumerState<EvidenceCaptureSheet> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleSelection(ImageSource source) async {
    final note = _noteController.text.trim().isEmpty
        ? null
        : _noteController.text.trim();

    if (widget.onSourceSelected != null) {
      widget.onSourceSelected!(source, note);
      Navigator.of(context).pop();
      return;
    }

    try {
      Navigator.of(context).pop();
      await ref
          .read(attendanceEvidenceProvider(widget.recordId).notifier)
          .captureAndSave(source: source, note: note);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save evidence: $e'),
            backgroundColor: ColorTokens.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.all(SpacingTokens.md),
      padding: EdgeInsets.only(
        left: SpacingTokens.lg,
        right: SpacingTokens.lg,
        top: SpacingTokens.lg,
        bottom: MediaQuery.of(context).padding.bottom +
            bottomInset +
            SpacingTokens.lg,
      ),
      decoration: BoxDecoration(
        color: ColorTokens.surfaceContainerHigh,
        borderRadius: RadiusTokens.borderRadiusXl,
        border: Border.all(color: ColorTokens.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: ColorTokens.background.withValues(alpha: 0.5),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ColorTokens.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: RadiusTokens.borderRadiusPill,
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.base),

          // Title & Description
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(SpacingTokens.sm),
                decoration: BoxDecoration(
                  color: ColorTokens.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Symbols.photo_camera,
                  color: ColorTokens.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attach Evidence',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: ColorTokens.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.xxs),
                    Text(
                      'Stored locally on this device only (never synced).',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ColorTokens.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.lg),

          // Optional Note input
          TextField(
            controller: _noteController,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: ColorTokens.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Note or description (optional)...',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: ColorTokens.onSurfaceVariant,
              ),
              prefixIcon: const Icon(
                Symbols.edit_note,
                color: ColorTokens.onSurfaceVariant,
              ),
              filled: true,
              fillColor: ColorTokens.surfaceContainerHighest,
              border: const OutlineInputBorder(
                borderRadius: RadiusTokens.borderRadiusMd,
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md,
                vertical: SpacingTokens.sm,
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),

          // Action Option 1: Take Photo (Camera)
          FilledButton.icon(
            onPressed: () => _handleSelection(ImageSource.camera),
            icon: const Icon(Symbols.photo_camera, size: 20),
            label: const Text('Take Photo'),
            style: FilledButton.styleFrom(
              backgroundColor: ColorTokens.primary,
              foregroundColor: ColorTokens.onPrimary,
              minimumSize: const Size(double.infinity, 48),
              padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
              shape: const RoundedRectangleBorder(
                borderRadius: RadiusTokens.borderRadiusLg,
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),

          // Action Option 2: Gallery Picker
          OutlinedButton.icon(
            onPressed: () => _handleSelection(ImageSource.gallery),
            icon: const Icon(Symbols.photo_library, size: 20),
            label: const Text('Choose from Gallery'),
            style: OutlinedButton.styleFrom(
              foregroundColor: ColorTokens.onSurface,
              side: const BorderSide(color: ColorTokens.outlineVariant),
              minimumSize: const Size(double.infinity, 48),
              padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
              shape: const RoundedRectangleBorder(
                borderRadius: RadiusTokens.borderRadiusLg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
