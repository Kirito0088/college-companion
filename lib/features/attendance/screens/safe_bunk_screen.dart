import 'package:college_companion/features/attendance/providers/attendance_provider.dart';
import 'package:college_companion/features/attendance/widgets/safe_bunk_app_bar.dart';
import 'package:college_companion/features/attendance/widgets/safe_bunk_ring.dart';
import 'package:college_companion/features/attendance/widgets/safe_bunk_stats.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SafeBunkScreen extends ConsumerWidget {
  const SafeBunkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final userId =
        authState is AuthAuthenticated && authState.user.uid.isNotEmpty
        ? authState.user.uid
        : 'default_user';

    final safeBunkAsync = ref.watch(safeBunkStreamProvider(userId));
    final safeBunk = safeBunkAsync.valueOrNull;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const SafeBunkAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: LayoutTokens.screenPadding,
                  vertical: SpacingTokens.md,
                ),
                child: Column(
                  children: [
                    SafeBunkRing(safeBunk: safeBunk),
                    const SizedBox(height: LayoutTokens.sectionGap),
                    SafeBunkStats(safeBunk: safeBunk),
                    const SizedBox(height: SpacingTokens.md),
                    const _SafeBunkNote(),
                    const SizedBox(height: SpacingTokens.xxxl),
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
    final cc = context.cc;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xs),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Note: This is an estimate.\nActual attendance may vary.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: cc.mut.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
