import 'package:college_companion/routing/app_router.dart';
import 'package:college_companion/shared/widgets/dialogs/cc_dialogs.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class EventDetailsScreen extends StatelessWidget {
  const EventDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(LayoutTokens.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Midterm Physics',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: ColorTokens.onSurface,
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.sm,
                      vertical: SpacingTokens.xs,
                    ),
                    decoration: BoxDecoration(
                      color: ColorTokens.error.withValues(alpha: 0.1),
                      borderRadius: RadiusTokens.borderRadiusSm,
                    ),
                    child: Text(
                      'Exam',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: ColorTokens.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.md),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: ColorTokens.onSurfaceVariant,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.md),
                  Text(
                    'Physics 101',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: ColorTokens.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.xl),
              _buildInfoCard(
                theme: theme,
                children: [
                  _buildInfoRow(
                    theme: theme,
                    icon: Symbols.calendar_today,
                    label: 'Date',
                    value: 'May 14, 2025',
                  ),
                  const Divider(
                    height: SpacingTokens.lg,
                    color: ColorTokens.surfaceVariant,
                  ),
                  _buildInfoRow(
                    theme: theme,
                    icon: Symbols.schedule,
                    label: 'Time',
                    value: '10:00 AM - 12:00 PM',
                  ),
                  const Divider(
                    height: SpacingTokens.lg,
                    color: ColorTokens.surfaceVariant,
                  ),
                  _buildInfoRow(
                    theme: theme,
                    icon: Symbols.location_on,
                    label: 'Location',
                    value: 'Room 304, Science Building',
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.lg),
              _buildInfoCard(
                theme: theme,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Symbols.notes,
                        size: 20,
                        color: ColorTokens.onSurfaceVariant,
                      ),
                      const SizedBox(width: SpacingTokens.md),
                      Text(
                        'Notes',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: ColorTokens.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  Text(
                    'Covers chapters 4 through 7. Bring a scientific calculator and student ID.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: ColorTokens.onSurface,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.xxl),
              FilledButton.icon(
                onPressed: () {
                  context.push(RoutePaths.addEditEvent);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: ColorTokens.primary,
                  foregroundColor: ColorTokens.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    vertical: SpacingTokens.md,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: RadiusTokens.borderRadiusMd,
                  ),
                ),
                icon: const Icon(Symbols.edit, size: 18),
                label: const Text('Edit Event'),
              ),
              const SizedBox(height: SpacingTokens.md),
              OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await CCDialogs.showDeleteConfirmation(
                    context,
                    title: 'Delete Event',
                    message: 'Are you sure you want to delete this event?',
                  );
                  if (confirm == true) {
                    if (context.mounted) {
                      context.pop();
                    }
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColorTokens.error,
                  side: const BorderSide(color: ColorTokens.error),
                  padding: const EdgeInsets.symmetric(
                    vertical: SpacingTokens.md,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: RadiusTokens.borderRadiusMd,
                  ),
                ),
                icon: const Icon(Symbols.delete, size: 18),
                label: const Text('Delete Event'),
              ),
              const SizedBox(height: SpacingTokens.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required ThemeData theme,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        color: ColorTokens.surfaceContainer,
        borderRadius: RadiusTokens.borderRadiusLg,
        border: Border.all(color: ColorTokens.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInfoRow({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: ColorTokens.onSurfaceVariant),
        const SizedBox(width: SpacingTokens.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: ColorTokens.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: SpacingTokens.xxs),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: ColorTokens.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
