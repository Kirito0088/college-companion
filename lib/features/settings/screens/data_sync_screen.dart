/// Data & Sync (#16)
///
/// What is saved where, from the real sync state: the queue's pending and
/// failed changes, connectivity, an upload in flight, and when the queue
/// last drained cleanly. Sync Now retries changes that gave up and uploads
/// what is waiting (sync-engine.md, Manual Sync).
library;

import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:college_companion/providers/sync_status_provider.dart';
import 'package:college_companion/shared/widgets/cc_card.dart';
import 'package:college_companion/shared/widgets/sync_status_text.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class DataSyncScreen extends ConsumerStatefulWidget {
  const DataSyncScreen({super.key});

  @override
  ConsumerState<DataSyncScreen> createState() => _DataSyncScreenState();
}

class _DataSyncScreenState extends ConsumerState<DataSyncScreen> {
  bool _busy = false;

  Future<void> _syncNow() async {
    setState(() => _busy = true);
    try {
      await ref.read(syncQueueRepositoryProvider).retryFailed();
      await ref.read(syncServiceProvider).syncPendingMutations();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;
    final status = ref.watch(syncStatusProvider);

    return Scaffold(
      backgroundColor: cc.bg,
      appBar: AppBar(
        backgroundColor: cc.bg,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back),
          tooltip: 'Back',
          color: cc.fg,
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Data & Sync',
          style: theme.textTheme.titleLarge?.copyWith(
            color: cc.fg,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: LayoutTokens.screenPadding,
          vertical: SpacingTokens.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (status == null)
              const Center(child: CircularProgressIndicator())
            else
              _SyncStatusCard(status: status, busy: _busy, onSyncNow: _syncNow),
            const SizedBox(height: LayoutTokens.sectionGap),
            const _AccountCard(),
            const SizedBox(height: LayoutTokens.sectionGap),
            const _InfoFooter(),
            const SizedBox(height: SpacingTokens.huge),
          ],
        ),
      ),
    );
  }
}

class _SyncStatusCard extends StatelessWidget {
  const _SyncStatusCard({
    required this.status,
    required this.busy,
    required this.onSyncNow,
  });

  final SyncStatus status;
  final bool busy;
  final VoidCallback onSyncNow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;
    final (:headline, :detail) = describeSync(status);
    final phase = status.phase;
    final syncing = busy || phase == SyncPhase.syncing;

    final (IconData icon, Color fg, Color bg) = switch (phase) {
      SyncPhase.offlineQueued ||
      SyncPhase.offline => (Symbols.cloud_off, cc.warn, cc.warnSoft),
      SyncPhase.needsAttention => (Symbols.sync_problem, cc.warn, cc.warnSoft),
      SyncPhase.syncing ||
      SyncPhase.waiting => (Symbols.sync, cc.pri, cc.priSoft),
      SyncPhase.upToDate => (Symbols.cloud_done, cc.pri, cc.priSoft),
    };

    return CCCard(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(SpacingTokens.md),
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, color: fg, size: 40, fill: 1.0),
          ),
          const SizedBox(height: SpacingTokens.md),
          Text(
            headline,
            style: theme.textTheme.titleLarge?.copyWith(
              color: cc.fg,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (detail != null) ...[
            const SizedBox(height: SpacingTokens.xs),
            Text(
              detail,
              style: theme.textTheme.bodyMedium?.copyWith(color: cc.mut),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: SpacingTokens.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              // Nothing to send while offline; the queue resumes by itself.
              onPressed: syncing || !status.online ? null : onSyncNow,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
                shape: const RoundedRectangleBorder(
                  borderRadius: RadiusTokens.borderRadiusLg,
                ),
              ),
              child: Text(syncing ? 'Syncing…' : 'Sync Now'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends ConsumerWidget {
  const _AccountCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cc = context.cc;
    final auth = ref.watch(authStateProvider);
    if (auth is! AuthAuthenticated) return const SizedBox.shrink();
    final user = auth.user;
    final initial = user.displayName.isNotEmpty
        ? user.displayName[0].toUpperCase()
        : (user.email.isNotEmpty ? user.email[0].toUpperCase() : '?');

    return CCCard(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cc.priSoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: theme.textTheme.titleLarge?.copyWith(
                color: cc.pri,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Backed up to',
                  style: theme.textTheme.labelMedium?.copyWith(color: cc.mut),
                ),
                Text(
                  user.email,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: cc.fg,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoFooter extends StatelessWidget {
  const _InfoFooter();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Symbols.info, size: 20, color: cc.mut),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Text(
              'Changes are saved on this device first and backed up to your '
              "account whenever you're online. Lecture photos stay on this "
              'device only.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cc.mut,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
