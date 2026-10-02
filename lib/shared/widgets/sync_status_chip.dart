/// Sync Status Chip (#16)
///
/// A quiet pill shown above the bottom navigation only when it tells the
/// student something useful (sync-engine.md, Sync Indicators):
///
/// - offline with changes waiting: "Offline — queued locally"
/// - an upload in progress: "Syncing…"
/// - a sync that just emptied the queue: "All changes synced", for three
///   seconds
///
/// Otherwise, including while the status is still loading, it renders
/// nothing. It sits above the navigation bar rather than at the top of the
/// screen so it never competes with the redesigned app bars.
library;

import 'dart:async';

import 'package:college_companion/providers/sync_status_provider.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

class SyncStatusChip extends ConsumerStatefulWidget {
  const SyncStatusChip({super.key});

  /// How long "All changes synced" stays up after a sync completes.
  static const Duration confirmationDuration = Duration(seconds: 3);

  @override
  ConsumerState<SyncStatusChip> createState() => _SyncStatusChipState();
}

class _SyncStatusChipState extends ConsumerState<SyncStatusChip> {
  bool _confirming = false;
  Timer? _confirmTimer;

  @override
  void dispose() {
    _confirmTimer?.cancel();
    super.dispose();
  }

  void _onStatus(SyncStatus? previous, SyncStatus? next) {
    final finished =
        previous?.phase == SyncPhase.syncing &&
        next?.phase == SyncPhase.upToDate;
    if (finished) {
      _confirmTimer?.cancel();
      setState(() => _confirming = true);
      _confirmTimer = Timer(SyncStatusChip.confirmationDuration, () {
        if (mounted) setState(() => _confirming = false);
      });
    } else if (next?.phase != SyncPhase.upToDate && _confirming) {
      _confirmTimer?.cancel();
      setState(() => _confirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SyncStatus?>(syncStatusProvider, _onStatus);
    final phase = ref.watch(syncStatusProvider)?.phase;
    final cc = context.cc;

    final ({IconData icon, String label, Color fg, Color bg})? look =
        switch (phase) {
          SyncPhase.offlineQueued => (
            icon: Symbols.cloud_off,
            label: 'Offline — queued locally',
            fg: cc.warn,
            bg: cc.warnSoft,
          ),
          SyncPhase.syncing => (
            icon: Symbols.sync,
            label: 'Syncing…',
            fg: cc.mut,
            bg: cc.raise,
          ),
          SyncPhase.upToDate when _confirming => (
            icon: Symbols.cloud_done,
            label: 'All changes synced',
            fg: cc.pri,
            bg: cc.priSoft,
          ),
          _ => null,
        };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: look == null
          ? const SizedBox.shrink()
          : Semantics(
              key: ValueKey(look.label),
              liveRegion: true,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.md,
                  vertical: SpacingTokens.xs,
                ),
                decoration: BoxDecoration(
                  color: look.bg,
                  borderRadius: RadiusTokens.borderRadiusPill,
                  border: Border.all(color: cc.line),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(look.icon, size: 16, color: look.fg),
                    const SizedBox(width: SpacingTokens.xs),
                    Flexible(
                      child: Text(
                        look.label,
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(color: look.fg),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
