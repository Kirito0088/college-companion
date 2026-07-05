import 'package:college_companion/shared/widgets/dialogs/cc_dialogs.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class AssignmentDetailsScreen extends StatelessWidget {
  const AssignmentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back, color: ColorTokens.onSurface),
          onPressed: () => context.pop(),
        ),
        title: const Text('Assignment Details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: LayoutTokens.screenPadding,
            vertical: SpacingTokens.base,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: SpacingTokens.xl),
              _buildDescription(theme),
              const SizedBox(height: SpacingTokens.xl),
              _buildImportantDates(theme),
              const SizedBox(height: SpacingTokens.xl),
              _buildAttachments(theme),
              const SizedBox(height: SpacingTokens.xl),
              _buildNotes(theme),
              const SizedBox(height: SpacingTokens.xl),
              _buildActions(context, theme),
              const SizedBox(height: SpacingTokens.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Operating Systems Assignment 3',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: ColorTokens.onSurface,
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          'Operating Systems',
          style: theme.textTheme.titleMedium?.copyWith(
            color: ColorTokens.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: SpacingTokens.md),
        Row(
          children: [
            _buildChip(theme, 'Pending', ColorTokens.warning),
            const SizedBox(width: SpacingTokens.sm),
            _buildPriorityIndicator(theme, 'High Priority', ColorTokens.error),
          ],
        ),
      ],
    );
  }

  Widget _buildChip(ThemeData theme, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: RadiusTokens.borderRadiusMd,
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator(ThemeData theme, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Symbols.flag, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: ColorTokens.onSurface,
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        Text(
          'Complete chapters 4 and 5 from the textbook and implement the memory management algorithm as discussed in the lab session. Ensure you write unit tests for the edge cases.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: ColorTokens.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildImportantDates(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Important Dates',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: ColorTokens.onSurface,
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        Container(
          padding: const EdgeInsets.all(SpacingTokens.md),
          decoration: const BoxDecoration(
            color: ColorTokens.surfaceContainer,
            borderRadius: RadiusTokens.borderRadiusLg,
          ),
          child: Column(
            children: [
              _buildDateRow(theme, 'Assigned', 'Aug 1, 2026'),
              const Divider(
                height: SpacingTokens.lg,
                color: ColorTokens.surfaceVariant,
              ),
              _buildDateRow(theme, 'Due', 'Tomorrow, 11:59 PM'),
              const Divider(
                height: SpacingTokens.lg,
                color: ColorTokens.surfaceVariant,
              ),
              _buildDateRow(theme, 'Submitted', 'Not submitted yet'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateRow(ThemeData theme, String label, String date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: ColorTokens.onSurfaceVariant,
          ),
        ),
        Text(
          date,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: ColorTokens.onSurface,
          ),
        ),
      ],
    );
  }

  // Assignment attachments reference locally stored Resources.
  //
  // Files are stored only once inside the local Resources module.
  //
  // Assignments reference those files instead of duplicating them.
  //
  // PDFs, DOCX, images, ZIP files, videos and other large files
  // remain strictly on the local device.
  Widget _buildAttachments(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attachments',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: ColorTokens.onSurface,
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          'NOTE: Attachments themselves will eventually be stored locally only.',
          style: theme.textTheme.labelSmall?.copyWith(
            color: ColorTokens.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        _buildAttachmentCard(
          theme,
          'Assignment3_Guidelines.pdf',
          'PDF • 1.2 MB',
          Symbols.picture_as_pdf,
        ),
        const SizedBox(height: SpacingTokens.sm),
        _buildAttachmentCard(
          theme,
          'Starter_Code.zip',
          'ZIP • 4.5 MB',
          Symbols.folder_zip,
        ),
      ],
    );
  }

  Widget _buildAttachmentCard(
    ThemeData theme,
    String name,
    String details,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        color: ColorTokens.surfaceContainer,
        borderRadius: RadiusTokens.borderRadiusMd,
        border: Border.all(color: ColorTokens.surfaceVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: ColorTokens.primary, size: 32),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ColorTokens.onSurface,
                  ),
                ),
                Text(
                  details,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: ColorTokens.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Symbols.download,
            color: ColorTokens.onSurfaceVariant,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildNotes(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: ColorTokens.onSurface,
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(SpacingTokens.md),
          decoration: const BoxDecoration(
            color: ColorTokens.surfaceContainer,
            borderRadius: RadiusTokens.borderRadiusLg,
          ),
          child: Text(
            'Need to ask professor about part 2 of the algorithm implementation.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: ColorTokens.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              // TODO: Mark Complete
            },
            icon: const Icon(Symbols.check_circle),
            label: const Text('Mark Complete'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
              shape: const RoundedRectangleBorder(
                borderRadius: RadiusTokens.borderRadiusMd,
              ),
              backgroundColor: ColorTokens.success,
              foregroundColor: ColorTokens.onPrimary,
            ),
          ),
        ),
        const SizedBox(height: SpacingTokens.md),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Edit
                },
                icon: const Icon(Symbols.edit),
                label: const Text('Edit'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: SpacingTokens.md,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: RadiusTokens.borderRadiusMd,
                  ),
                  side: const BorderSide(color: ColorTokens.surfaceVariant),
                  foregroundColor: ColorTokens.onSurface,
                ),
              ),
            ),
            const SizedBox(width: SpacingTokens.md),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await CCDialogs.showDeleteConfirmation(
                    context,
                    title: 'Delete Assignment',
                    message:
                        'Are you sure you want to delete this assignment? This action cannot be undone.',
                  );
                  if (confirm == true) {
                    if (context.mounted) {
                      context.pop();
                    }
                  }
                },
                icon: const Icon(Symbols.delete),
                label: const Text('Delete'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: SpacingTokens.md,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: RadiusTokens.borderRadiusMd,
                  ),
                  side: const BorderSide(color: ColorTokens.error),
                  foregroundColor: ColorTokens.error,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
