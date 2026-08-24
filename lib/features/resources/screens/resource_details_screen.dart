import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/resources/providers/resources_provider.dart';
import 'package:college_companion/features/subjects/providers/subjects_provider.dart';
import 'package:college_companion/services/resource_file_service.dart';
import 'package:college_companion/shared/widgets/cc_empty_state.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:open_filex/open_filex.dart';

// OFFLINE-FIRST ARCHITECTURE
//
// Resources are stored only on the local device.
// SQLite/Drift indexes metadata.
// Actual files remain in local storage.
//
// Supabase is intentionally NOT used for storing
// PDFs, images, videos, or other large assets.

/// Displays real metadata for a single resource, resolved by [resourceId]
/// from [ResourcesRepository], and opens the underlying local file in the
/// native OS viewer.
class ResourceDetailsScreen extends ConsumerStatefulWidget {
  const ResourceDetailsScreen({super.key, required this.resourceId});

  final String resourceId;

  @override
  ConsumerState<ResourceDetailsScreen> createState() =>
      _ResourceDetailsScreenState();
}

class _ResourceDetailsScreenState extends ConsumerState<ResourceDetailsScreen> {
  String get _userId {
    final auth = ref.read(authStateProvider);
    return auth is AuthAuthenticated ? auth.user.uid : 'default_user';
  }

  Future<void> _openFile(ResourceEntity resource) async {
    final result = await ref
        .read(resourceFileServiceProvider)
        .open(resource.url);
    if (!mounted) return;
    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_openFailureMessage(result.type))));
    }
  }

  String _openFailureMessage(ResultType type) {
    switch (type) {
      case ResultType.fileNotFound:
        return 'This file is not available on this device.';
      case ResultType.noAppToOpen:
        return 'No app on this device can open this file type.';
      case ResultType.permissionDenied:
        return 'Permission denied while opening this file.';
      case ResultType.done:
      case ResultType.error:
        return 'Could not open this file.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(resourcesRepositoryProvider);

    return StreamBuilder<ResourceEntity?>(
      stream: repo.watchById(_userId, widget.resourceId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: _buildAppBar(context),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final resource = snapshot.data;
        if (resource == null) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: _buildAppBar(context),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(SpacingTokens.xl),
                child: CCEmptyState(
                  icon: Symbols.find_in_page,
                  title: 'Resource not found',
                  subtitle:
                      'This resource may have been removed or does not exist.',
                ),
              ),
            ),
          );
        }

        return _ResourceDetailsBody(
          resource: resource,
          onOpen: () => _openFile(resource),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Symbols.arrow_back),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          }
        },
      ),
    );
  }
}

/// File extension (uppercased, no dot) parsed from a resource's relative path.
String _fileExtension(String relativePath) {
  final lastDot = relativePath.lastIndexOf('.');
  final lastSlash = relativePath.lastIndexOf('/');
  if (lastDot <= lastSlash || lastDot == relativePath.length - 1) {
    return 'FILE';
  }
  return relativePath.substring(lastDot + 1).toUpperCase();
}

String _formatFileSize(int bytes) {
  const kb = 1024;
  const mb = 1024 * 1024;
  if (bytes <= 0) return '0 KB';
  if (bytes < mb) return '${(bytes / kb).toStringAsFixed(1)} KB';
  return '${(bytes / mb).toStringAsFixed(1)} MB';
}

class _ResourceDetailsBody extends ConsumerStatefulWidget {
  const _ResourceDetailsBody({required this.resource, required this.onOpen});

  final ResourceEntity resource;
  final VoidCallback onOpen;

  @override
  ConsumerState<_ResourceDetailsBody> createState() =>
      _ResourceDetailsBodyState();
}

class _ResourceDetailsBodyState extends ConsumerState<_ResourceDetailsBody> {
  late Future<ResourceFileInfo> _fileInfoFuture;
  late Future<String> _subjectNameFuture;

  @override
  void initState() {
    super.initState();
    _loadFor(widget.resource);
  }

  @override
  void didUpdateWidget(covariant _ResourceDetailsBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resource.id != widget.resource.id ||
        oldWidget.resource.url != widget.resource.url) {
      _loadFor(widget.resource);
    }
  }

  void _loadFor(ResourceEntity resource) {
    _fileInfoFuture = ref.read(resourceFileServiceProvider).stat(resource.url);
    _subjectNameFuture = _resolveSubjectName(resource);
  }

  Future<String> _resolveSubjectName(ResourceEntity resource) async {
    final subjectId = resource.subjectId;
    if (subjectId == null || subjectId.isEmpty) return 'General';
    final subject = await ref
        .read(subjectRepositoryProvider)
        .getById(resource.userId, subjectId);
    return subject?.name ?? 'General';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resource = widget.resource;
    final extension = _fileExtension(resource.url);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Symbols.more_vert),
            onPressed: () {
              // TODO: Show context menu
            },
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<ResourceFileInfo>(
          future: _fileInfoFuture,
          builder: (context, fileSnapshot) {
            final fileInfo = fileSnapshot.data;
            return FutureBuilder<String>(
              future: _subjectNameFuture,
              builder: (context, subjectSnapshot) {
                final subjectName = subjectSnapshot.data ?? 'General';
                return SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    left: LayoutTokens.screenPadding,
                    right: LayoutTokens.screenPadding,
                    bottom:
                        LayoutTokens.bottomNavigationHeight + SpacingTokens.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeroCard(
                        context,
                        resource,
                        extension,
                        subjectName,
                        fileInfo,
                      ),
                      const SizedBox(height: SpacingTokens.xl),
                      _buildQuickActions(context, fileInfo),
                      const SizedBox(height: SpacingTokens.xl),
                      _buildFileInformation(context, resource, subjectName),
                      const SizedBox(height: SpacingTokens.xl),
                      _buildStorageInformationCard(context, fileInfo),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    ResourceEntity resource,
    String extension,
    String subjectName,
    ResourceFileInfo? fileInfo,
  ) {
    final theme = Theme.of(context);
    final cc = context.cc;
    final isPdf = extension == 'PDF';
    final iconColor = cc.pri;
    final sizeLabel = fileInfo == null
        ? '…'
        : _formatFileSize(fileInfo.sizeBytes);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(SpacingTokens.xxl),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isPdf ? Symbols.picture_as_pdf : Symbols.description,
            size: 64,
            color: iconColor,
          ),
        ),
        const SizedBox(height: SpacingTokens.lg),
        Text(
          resource.title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: cc.fg,
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          subjectName,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            color: cc.pri,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md,
                vertical: SpacingTokens.xxs,
              ),
              decoration: BoxDecoration(
                color: cc.raise,
                borderRadius: RadiusTokens.borderRadiusSm,
              ),
              child: Text(
                extension,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cc.mut,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: SpacingTokens.md),
            Text(
              sizeLabel,
              style: theme.textTheme.bodyMedium?.copyWith(color: cc.mut),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, ResourceFileInfo? fileInfo) {
    final cc = context.cc;
    final canOpen = fileInfo?.exists ?? false;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          context,
          key: 'open',
          label: 'Open',
          icon: Symbols.open_in_new,
          onTap: canOpen ? widget.onOpen : null,
        ),
        _buildActionButton(
          context,
          key: 'share',
          label: 'Share',
          icon: Symbols.share,
          onTap: () {
            // TODO: Implement share file logic
          },
        ),
        _buildActionButton(
          context,
          key: 'rename',
          label: 'Rename',
          icon: Symbols.edit,
          onTap: () {
            // TODO: Implement rename file logic
          },
        ),
        _buildActionButton(
          context,
          key: 'delete',
          label: 'Delete',
          icon: Symbols.delete,
          onTap: () {
            // TODO: Implement delete file logic
          },
          isDestructive: true,
          color: cc.risk,
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String key,
    required String label,
    required IconData icon,
    required VoidCallback? onTap,
    bool isDestructive = false,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final cc = context.cc;
    final resolvedColor = color ?? (isDestructive ? cc.risk : cc.pri);
    final isDisabled = onTap == null;

    return Column(
      children: [
        IconButton(
          key: Key('resource_action_$key'),
          onPressed: onTap,
          icon: Icon(icon),
          color: isDisabled ? cc.mut : resolvedColor,
          style: IconButton.styleFrom(
            backgroundColor: (isDisabled ? cc.mut : resolvedColor).withValues(
              alpha: 0.1,
            ),
            padding: const EdgeInsets.all(SpacingTokens.md),
            shape: const CircleBorder(),
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isDisabled ? cc.mut : (isDestructive ? cc.risk : cc.mut),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFileInformation(
    BuildContext context,
    ResourceEntity resource,
    String subjectName,
  ) {
    final theme = Theme.of(context);
    final cc = context.cc;
    final createdLabel = _formatDate(resource.createdAt);
    final modifiedLabel = _formatDate(resource.updatedAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: SpacingTokens.sm,
            bottom: SpacingTokens.sm,
          ),
          child: Text(
            'File Information',
            style: theme.textTheme.titleMedium?.copyWith(
              color: cc.fg,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(LayoutTokens.cardPadding),
          decoration: BoxDecoration(
            color: cc.raise,
            borderRadius: RadiusTokens.borderRadiusXl,
          ),
          child: Column(
            children: [
              _buildInfoRow(context, 'Subject', subjectName),
              Divider(height: SpacingTokens.xl, color: cc.line),
              _buildInfoRow(context, 'Category', _titleCase(resource.category)),
              Divider(height: SpacingTokens.xl, color: cc.line),
              _buildInfoRow(context, 'Location', resource.url),
              Divider(height: SpacingTokens.xl, color: cc.line),
              _buildInfoRow(context, 'Created', createdLabel),
              Divider(height: SpacingTokens.xl, color: cc.line),
              _buildInfoRow(context, 'Modified', modifiedLabel),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final cc = context.cc;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: cc.mut)),
        const SizedBox(width: SpacingTokens.md),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cc.fg,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStorageInformationCard(
    BuildContext context,
    ResourceFileInfo? fileInfo,
  ) {
    final theme = Theme.of(context);
    final cc = context.cc;
    final isMissing = fileInfo != null && !fileInfo.exists;
    final color = isMissing ? cc.warn : cc.pri;
    final softColor = isMissing ? cc.warnSoft : cc.priSoft;

    return Container(
      padding: const EdgeInsets.all(LayoutTokens.cardPadding),
      decoration: BoxDecoration(
        color: softColor,
        borderRadius: RadiusTokens.borderRadiusLg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isMissing ? Symbols.cloud_off : Symbols.offline_pin,
            color: color,
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMissing ? 'File not available' : 'Stored locally',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  isMissing
                      ? 'This resource is not available on this device. It may have been cleared from local storage.'
                      : 'This resource is available offline and remains only on this device.\n\nIt is never uploaded to your cloud account.',
                  style: theme.textTheme.bodySmall?.copyWith(color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoString) {
    try {
      return DateFormat('MMM d, yyyy').format(DateTime.parse(isoString));
    } catch (_) {
      return isoString;
    }
  }

  String _titleCase(String value) {
    final normalized = value.replaceAll('_', ' ').trim();
    if (normalized.isEmpty) return normalized;
    return normalized
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}
