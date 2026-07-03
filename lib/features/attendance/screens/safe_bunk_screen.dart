import 'package:college_companion/features/attendance/widgets/safe_bunk_app_bar.dart';
import 'package:college_companion/features/attendance/widgets/safe_bunk_ring.dart';
import 'package:college_companion/features/attendance/widgets/safe_bunk_stats.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

class SafeBunkScreen extends StatelessWidget {
  const SafeBunkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: const SafeArea(
        child: Column(
          children: [
            SafeBunkAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal:
                      LayoutTokens.screenPadding, // 20px screen edge usually
                  vertical: SpacingTokens.md,
                ),
                child: Column(
                  children: [
                    SafeBunkRing(),
                    SizedBox(height: LayoutTokens.sectionGap),
                    SafeBunkStats(),
                    SizedBox(height: SpacingTokens.md),
                    _SafeBunkNote(),
                    SizedBox(height: SpacingTokens.xxxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SafeBunkNote extends StatelessWidget {
  const _SafeBunkNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xs),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Note: This is an estimate.\nActual attendance may vary.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: ColorTokens.onSurfaceVariant.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
