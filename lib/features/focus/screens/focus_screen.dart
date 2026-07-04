import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  bool _isRunning = false;
  String _selectedPreset = '25 min';
  bool _dndEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back),
          color: ColorTokens.onSurface,
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            Text(
              'Focus Mode',
              style: theme.textTheme.titleLarge?.copyWith(
                color: ColorTokens.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Stay focused. Study smarter.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: ColorTokens.onSurfaceVariant,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: LayoutTokens.screenPadding,
          vertical: SpacingTokens.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeroTimer(context),
            const SizedBox(height: SpacingTokens.xl),
            _buildSessionControls(),
            const SizedBox(height: SpacingTokens.xl),
            _buildSessionPresets(),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildStatisticsCard(context),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildStudyGoalCard(context),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildAmbientModeCard(context),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildDndCard(context),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildSessionHistory(context),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildMotivationalCard(context),
            const SizedBox(height: SpacingTokens.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroTimer(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SizedBox(
        width: 276,
        height: 276,
        child: Stack(
          fit: StackFit.expand,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 0.75),
              duration: const Duration(seconds: 1),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: 10,
                  backgroundColor: ColorTokens.surfaceContainerHighest,
                  color: ColorTokens.primary,
                  strokeCap: StrokeCap.round,
                );
              },
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '25:00',
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: 62,
                    color: ColorTokens.onSurface,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  'Focus Session',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: ColorTokens.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: SpacingTokens.md + 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.lg,
                    vertical: SpacingTokens.sm,
                  ),
                  decoration: BoxDecoration(
                    color: ColorTokens.surfaceContainerHigh.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: RadiusTokens.borderRadiusSm,
                  ),
                  child: Text(
                    "Today's Progress: 2 / 8 Sessions",
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: ColorTokens.onSurfaceVariant.withValues(
                        alpha: 0.8,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionControls() {
    return _isRunning
        ? Row(
            children: [
              Expanded(
                child: _buildAnimatedButton(
                  onTap: () {
                    setState(() {
                      _isRunning = false;
                    });
                  },
                  icon: Symbols.pause,
                  label: 'Pause',
                  backgroundColor: ColorTokens.surfaceContainerHigh,
                  foregroundColor: ColorTokens.onSurface,
                ),
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: _buildAnimatedButton(
                  onTap: () {
                    setState(() {
                      _isRunning = false;
                    });
                  },
                  icon: Symbols.stop,
                  label: 'End Session',
                  backgroundColor: ColorTokens.error.withValues(alpha: 0.9),
                  foregroundColor: ColorTokens.onError,
                ),
              ),
            ],
          )
        : _buildAnimatedButton(
            onTap: () {
              setState(() {
                _isRunning = true;
              });
            },
            icon: Symbols.play_arrow,
            label: 'Start Focus Session',
            backgroundColor: ColorTokens.primary.withValues(alpha: 0.85),
            foregroundColor: ColorTokens.onPrimary,
          );
  }

  Widget _buildAnimatedButton({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: SpacingTokens.xl,
            horizontal: SpacingTokens.xl,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foregroundColor),
              const SizedBox(width: SpacingTokens.sm),
              Text(
                label,
                style: TextStyle(
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionPresets() {
    final presets = ['25 min', '45 min', '60 min', 'Custom'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: presets.map((preset) {
          final isSelected = _selectedPreset == preset;
          return Padding(
            padding: const EdgeInsets.only(right: SpacingTokens.md),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: ChoiceChip(
                label: Text(preset),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedPreset = preset;
                    });
                  }
                },
                selectedColor: ColorTokens.primaryContainer,
                labelPadding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.md,
                ),
                labelStyle: TextStyle(
                  color: isSelected
                      ? ColorTokens.onPrimaryContainer
                      : ColorTokens.onSurfaceVariant.withValues(alpha: 0.7),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: RadiusTokens.borderRadiusLg,
                  side: BorderSide(
                    color: isSelected
                        ? Colors.transparent
                        : ColorTokens.outlineVariant.withValues(alpha: 0.2),
                  ),
                ),
                backgroundColor: ColorTokens.surfaceContainer,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatisticsCard(BuildContext context) {
    return _buildSectionContainer(
      context: context,
      title: "Today's Focus",
      child: Row(
        children: [
          Expanded(child: _buildStatItem(context, 'Focus Time', '2h 15m')),
          Container(
            width: 1,
            height: 40,
            color: ColorTokens.outlineVariant.withValues(alpha: 0.15),
          ),
          Expanded(child: _buildStatItem(context, 'Sessions', '5')),
          Container(
            width: 1,
            height: 40,
            color: ColorTokens.outlineVariant.withValues(alpha: 0.15),
          ),
          Expanded(child: _buildStatItem(context, 'Streak', '3')),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: ColorTokens.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: ColorTokens.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStudyGoalCard(BuildContext context) {
    final theme = Theme.of(context);
    return _buildSectionContainer(
      context: context,
      title: "Today's Goal",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: ColorTokens.onSurfaceVariant,
                ),
              ),
              Text(
                '5 / 8 Sessions',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: ColorTokens.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.lg),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 5 / 8),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                backgroundColor: ColorTokens.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                color: ColorTokens.primary,
                minHeight: 10,
                borderRadius: BorderRadius.circular(100),
              );
            },
          ),
          const SizedBox(height: SpacingTokens.lg),
          Row(
            children: [
              const Icon(
                Symbols.emoji_events,
                color: ColorTokens.tertiary,
                size: 20,
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Text(
                  "Keep going! You're making great progress.",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: ColorTokens.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientModeCard(BuildContext context) {
    final environments = [
      {'icon': Symbols.water_drop, 'label': 'Rain Sounds'},
      {'icon': Symbols.forest, 'label': 'Forest'},
      {'icon': Symbols.waves, 'label': 'White Noise'},
      {'icon': Symbols.volume_off, 'label': 'None'},
    ];

    return _buildSectionContainer(
      context: context,
      title: 'Study Environment',
      padding: EdgeInsets.zero,
      child: Column(
        children: environments.asMap().entries.map((entry) {
          final index = entry.key;
          final env = entry.value;
          return _ActionRow(
            icon: env['icon'] as IconData,
            label: env['label'] as String,
            showBorder: index != environments.length - 1,
            isSelected: index == 0,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDndCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LayoutTokens.cardPadding,
        vertical: LayoutTokens.cardPadding + 8,
      ),
      decoration: const BoxDecoration(
        color: ColorTokens.surfaceContainer,
        borderRadius: RadiusTokens.borderRadiusXl,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Symbols.do_not_disturb_on,
            color: ColorTokens.onSurfaceVariant,
          ),
          const SizedBox(width: SpacingTokens.base),
          Expanded(
            child: Text(
              'Automatically enable Do Not Disturb while studying',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ColorTokens.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          Switch(
            value: _dndEnabled,
            onChanged: (val) {
              setState(() {
                _dndEnabled = val;
              });
            },
            activeThumbColor: ColorTokens.surface,
            activeTrackColor: ColorTokens.primary,
            inactiveThumbColor: ColorTokens.outline,
            inactiveTrackColor: ColorTokens.surfaceContainerHighest,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionHistory(BuildContext context) {
    final theme = Theme.of(context);
    final history = [
      {
        'subject': 'Mathematics',
        'duration': '25 min',
        'icon': Symbols.calculate,
      },
      {
        'subject': 'Operating Systems',
        'duration': '45 min',
        'icon': Symbols.memory,
      },
      {
        'subject': 'DBMS Revision',
        'duration': '25 min',
        'icon': Symbols.database,
      },
    ];

    return _buildSectionContainer(
      context: context,
      title: 'Recent Sessions',
      padding: EdgeInsets.zero,
      child: Column(
        children: history.asMap().entries.map((entry) {
          final index = entry.key;
          final session = entry.value;
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: LayoutTokens.cardPadding,
              vertical: LayoutTokens.cardPadding + 4,
            ),
            decoration: BoxDecoration(
              border: index != history.length - 1
                  ? Border(
                      bottom: BorderSide(
                        color: ColorTokens.outlineVariant.withValues(
                          alpha: 0.15,
                        ),
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(SpacingTokens.sm),
                  decoration: const BoxDecoration(
                    color: ColorTokens.surfaceContainerHigh,
                    borderRadius: RadiusTokens.borderRadiusSm,
                  ),
                  child: Icon(
                    session['icon'] as IconData,
                    size: 20,
                    color: ColorTokens.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: SpacingTokens.md + 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session['subject'] as String,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: ColorTokens.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        session['duration'] as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: ColorTokens.onSurfaceVariant.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Symbols.check_circle,
                  color: ColorTokens.primary,
                  size: 20,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMotivationalCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.xl,
        vertical: SpacingTokens.lg,
      ),
      decoration: BoxDecoration(
        color: ColorTokens.primaryContainer.withValues(alpha: 0.3),
        borderRadius: RadiusTokens.borderRadiusLg,
      ),
      child: Row(
        children: [
          const Icon(
            Symbols.format_quote,
            size: 40,
            color: ColorTokens.primary,
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Text(
              '"Small progress every day adds up to big results."',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ColorTokens.onSurface.withValues(alpha: 0.8),
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({
    required BuildContext context,
    required String title,
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: SpacingTokens.sm,
            bottom: SpacingTokens.sm,
          ),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: ColorTokens.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding:
              padding ??
              const EdgeInsets.symmetric(
                horizontal: LayoutTokens.cardPadding,
                vertical: LayoutTokens.cardPadding + 4,
              ),
          decoration: const BoxDecoration(
            color: ColorTokens.surfaceContainer,
            borderRadius: RadiusTokens.borderRadiusXl,
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.showBorder,
    this.isSelected = false,
  });

  final IconData icon;
  final String label;
  final bool showBorder;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        hoverColor: ColorTokens.surfaceContainerHigh,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: LayoutTokens.cardPadding,
            vertical: LayoutTokens.cardPadding + 4,
          ),
          decoration: BoxDecoration(
            border: showBorder
                ? Border(
                    bottom: BorderSide(
                      color: ColorTokens.outlineVariant.withValues(alpha: 0.15),
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? ColorTokens.primary
                    : ColorTokens.onSurfaceVariant.withValues(alpha: 0.6),
                size: 22,
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isSelected
                        ? ColorTokens.primary
                        : ColorTokens.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Symbols.check, color: ColorTokens.primary, size: 20)
              else
                Icon(
                  Symbols.chevron_right,
                  color: ColorTokens.onSurfaceVariant.withValues(alpha: 0.6),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
