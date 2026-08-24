import 'package:college_companion/shared/widgets/cc_card.dart';
import 'package:college_companion/shared/widgets/cc_list_row.dart';
import 'package:college_companion/shared/widgets/cc_section.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataSyncScreen extends StatefulWidget {
  const DataSyncScreen({super.key});

  @override
  State<DataSyncScreen> createState() => _DataSyncScreenState();
}

class _DataSyncScreenState extends State<DataSyncScreen> {
  bool _isSyncing = false;
  String _lastSynced = 'Never';

  @override
  void initState() {
    super.initState();
    _loadLastSync();
  }

  Future<void> _loadLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('last_sync_timestamp');
    if (timestamp != null) {
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      setState(() {
        _lastSynced = DateFormat('MMM d, y, h:mm a').format(date);
      });
    }
  }

  Future<void> _performSync() async {
    setState(() {
      _isSyncing = true;
    });

    // Simulate sync delay
    await Future<void>.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setInt('last_sync_timestamp', now.millisecondsSinceEpoch);

    if (mounted) {
      setState(() {
        _isSyncing = false;
        _lastSynced = DateFormat('MMM d, y, h:mm a').format(now);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data synced successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;

    return Scaffold(
      backgroundColor: cc.bg,
      appBar: AppBar(
        backgroundColor: cc.bg,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back),
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
            _buildSyncStatusCard(context),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildAccountInfoCard(context),
            const SizedBox(height: LayoutTokens.sectionGap),
            CCSection(
              title: 'Sync Preferences',
              children: [
                CCListRow(
                  icon: Symbols.autorenew,
                  label: 'Auto Sync',
                  showBorder: true,
                  trailing: Switch(value: true, onChanged: (val) {}),
                ),
                CCListRow(
                  icon: Symbols.wifi,
                  label: 'Sync over Wi-Fi only',
                  showBorder: true,
                  trailing: Switch(value: true, onChanged: (val) {}),
                ),
                CCListRow(
                  icon: Symbols.cached,
                  label: 'Background Sync',
                  showBorder: false,
                  trailing: Switch(value: false, onChanged: (val) {}),
                ),
              ],
            ),
            const SizedBox(height: LayoutTokens.sectionGap),
            const CCSection(
              title: 'Storage & Cache',
              children: [
                CCListRow(
                  icon: Symbols.sd_storage,
                  label: 'Local Storage',
                  trailingText: '12.4 MB',
                  hideChevron: true,
                  showBorder: true,
                ),
                CCListRow(
                  icon: Symbols.cloud,
                  label: 'Cloud Storage',
                  trailingText: '45.1 MB',
                  hideChevron: true,
                  showBorder: true,
                ),
                CCListRow(
                  icon: Symbols.memory,
                  label: 'Cache',
                  trailingText: '8.2 MB',
                  hideChevron: true,
                  showBorder: false,
                ),
              ],
            ),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildInfoFooter(context),
            const SizedBox(height: SpacingTokens.huge),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatusCard(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;

    return CCCard(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(SpacingTokens.md),
            decoration: BoxDecoration(
              color: cc.priSoft,
              shape: BoxShape.circle,
            ),
            child: _isSyncing
                ? SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(color: cc.pri),
                  )
                : Icon(
                    Symbols.check_circle,
                    color: cc.pri,
                    size: 40,
                    fill: 1.0,
                  ),
          ),
          const SizedBox(height: SpacingTokens.md),
          Text(
            _isSyncing ? 'Syncing data...' : 'All data synced',
            style: theme.textTheme.titleLarge?.copyWith(
              color: cc.fg,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            'Last synced: $_lastSynced',
            style: theme.textTheme.bodyMedium?.copyWith(color: cc.mut),
          ),
          const SizedBox(height: SpacingTokens.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSyncing ? null : _performSync,
              style: ElevatedButton.styleFrom(
                backgroundColor: cc.pri,
                foregroundColor: cc.priFg,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
                shape: const RoundedRectangleBorder(
                  borderRadius: RadiusTokens.borderRadiusLg,
                ),
              ),
              child: Text(
                _isSyncing ? 'Syncing...' : 'Sync Now',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;

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
              'J',
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
                  'Syncing to',
                  style: theme.textTheme.labelMedium?.copyWith(color: cc.mut),
                ),
                Text(
                  'jayeshpatil@gmail.com',
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

  Widget _buildInfoFooter(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Symbols.info, size: 20, color: cc.mut),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Text(
              'Data is encrypted locally and in transit. Your college credentials are never sent to our servers.',
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
