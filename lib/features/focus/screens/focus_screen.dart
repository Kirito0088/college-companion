import 'package:college_companion/features/focus/models/focus_timer_state.dart';
import 'package:college_companion/features/focus/providers/focus_timer_provider.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> {
  int _selectedEnvironmentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timerState = ref.watch(focusTimerProvider);
    final timerNotifier = ref.read(focusTimerProvider.notifier);

    ref.listen<FocusTimerState>(focusTimerProvider, (previous, next) {
      if (next.completionAlertMessage != null &&
          next.completionAlertMessage != previous?.completionAlertMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Symbols.notifications_active, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    next.completionAlertMessage!,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: ColorTokens.primary,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(
              borderRadius: RadiusTokens.borderRadiusMd,
            ),
          ),
        );
        timerNotifier.clearAlertMessage();
      }
    });

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
              timerState.isBreak ? 'Break Time' : 'Stay focused. Study smarter.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: timerState.isBreak ? ColorTokens.tertiary : ColorTokens.onSurfaceVariant,
                fontWeight: timerState.isBreak ? FontWeight.bold : FontWeight.normal,
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
            _buildHeroTimer(context, timerState),
            const SizedBox(height: SpacingTokens.xl),
            _buildSessionControls(timerState, timerNotifier),
            const SizedBox(height: SpacingTokens.xl),
            _buildSessionPresets(timerState, timerNotifier),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildStatisticsCard(context, timerState),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildStudyGoalCard(context, timerState),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildAmbientModeCard(context),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildDndCard(context, timerState, timerNotifier),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildSessionHistory(context, timerState),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildMotivationalCard(context),
            const SizedBox(height: SpacingTokens.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroTimer(BuildContext context, FocusTimerState state) {
    final theme = Theme.of(context);
    final isBreak = state.isBreak;
    final progressColor = isBreak ? ColorTokens.tertiary : ColorTokens.primary;

    return Center(
      child: SizedBox(
        width: 276,
        height: 276,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              value: state.progress,
              strokeWidth: 10,
              backgroundColor: ColorTokens.surfaceContainerHighest,
              color: progressColor,
              strokeCap: StrokeCap.round,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.formattedTime,
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: 62,
                    color: ColorTokens.onSurface,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  isBreak ? 'Break Session' : 'Focus Session',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isBreak ? ColorTokens.tertiary : ColorTokens.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
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
                    "Today's Progress: ${state.completedSessionsToday} / 8 Sessions",
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

  Widget _buildSessionControls(FocusTimerState state, FocusTimerNotifier notifier) {
    if (state.status == FocusTimerStatus.running || state.status == FocusTimerStatus.breakMode) {
      return Row(
        children: [
          Expanded(
            child: _buildAnimatedButton(
              onTap: () => notifier.pause(),
              icon: Symbols.pause,
              label: 'Pause',
              backgroundColor: ColorTokens.surfaceContainerHigh,
              foregroundColor: ColorTokens.onSurface,
            ),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: _buildAnimatedButton(
              onTap: () => notifier.stop(),
              icon: Symbols.stop,
              label: 'End Session',
              backgroundColor: ColorTokens.error.withValues(alpha: 0.9),
              foregroundColor: ColorTokens.onError,
            ),
          ),
        ],
      );
    } else if (state.status == FocusTimerStatus.paused) {
      return Row(
        children: [
          Expanded(
            child: _buildAnimatedButton(
              onTap: () => notifier.start(),
              icon: Symbols.play_arrow,
              label: 'Resume',
              backgroundColor: ColorTokens.primary.withValues(alpha: 0.85),
              foregroundColor: ColorTokens.onPrimary,
            ),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: _buildAnimatedButton(
              onTap: () => notifier.stop(),
              icon: Symbols.refresh,
              label: 'Reset',
              backgroundColor: ColorTokens.surfaceContainerHigh,
              foregroundColor: ColorTokens.onSurface,
            ),
          ),
        ],
      );
    } else {
      return _buildAnimatedButton(
        onTap: () => notifier.start(),
        icon: Symbols.play_arrow,
        label: 'Start Focus Session',
        backgroundColor: ColorTokens.primary.withValues(alpha: 0.85),
        foregroundColor: ColorTokens.onPrimary,
      );
    }
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

  Widget _buildSessionPresets(FocusTimerState state, FocusTimerNotifier notifier) {
    final presets = [
      {'label': '25 min', 'work': 25, 'break': 5},
      {'label': '45 min', 'work': 45, 'break': 10},
      {'label': '60 min', 'work': 60, 'break': 15},
      {'label': 'Custom', 'work': 30, 'break': 5},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: presets.map((preset) {
          final label = preset['label'] as String;
          final isSelected = state.selectedPreset == label;
          return Padding(
            padding: const EdgeInsets.only(right: SpacingTokens.md),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: ChoiceChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    if (label == 'Custom') {
                      _showCustomDurationDialog(context, state, notifier);
                    } else {
                      notifier.setPreset(
                        label,
                        workMinutes: preset['work'] as int,
                        breakMinutes: preset['break'] as int,
                      );
                    }
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

  void _showCustomDurationDialog(
    BuildContext context,
    FocusTimerState state,
    FocusTimerNotifier notifier,
  ) {
    int workMins = state.workDurationMinutes;
    int breakMins = state.breakDurationMinutes;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Custom Focus Timer'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Focus Duration: $workMins mins'),
                  Slider(
                    value: workMins.toDouble(),
                    min: 5,
                    max: 120,
                    divisions: 23,
                    label: '$workMins min',
                    onChanged: (val) {
                      setDialogState(() {
                        workMins = val.toInt();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Break Duration: $breakMins mins'),
                  Slider(
                    value: breakMins.toDouble(),
                    min: 1,
                    max: 30,
                    divisions: 29,
                    label: '$breakMins min',
                    onChanged: (val) {
                      setDialogState(() {
                        breakMins = val.toInt();
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    notifier.setPreset(
                      'Custom',
                      workMinutes: workMins,
                      breakMinutes: breakMins,
                    );
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Set'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatisticsCard(BuildContext context, FocusTimerState state) {
    final totalMins = state.history.fold<int>(0, (sum, s) => sum + s.durationMinutes);
    final hours = totalMins ~/ 60;
    final mins = totalMins % 60;
    final focusTimeString = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';

    return _buildSectionContainer(
      context: context,
      title: "Today's Focus",
      child: Row(
        children: [
          Expanded(child: _buildStatItem(context, 'Focus Time', focusTimeString)),
          Container(
            width: 1,
            height: 40,
            color: ColorTokens.outlineVariant.withValues(alpha: 0.15),
          ),
          Expanded(
            child: _buildStatItem(
              context,
              'Sessions',
              '${state.completedSessionsToday}',
            ),
          ),
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

  Widget _buildStudyGoalCard(BuildContext context, FocusTimerState state) {
    final theme = Theme.of(context);
    final goalProgress = (state.completedSessionsToday / 8).clamp(0.0, 1.0);

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
                '${state.completedSessionsToday} / 8 Sessions',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: ColorTokens.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.lg),
          LinearProgressIndicator(
            value: goalProgress,
            backgroundColor: ColorTokens.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            color: ColorTokens.primary,
            minHeight: 10,
            borderRadius: BorderRadius.circular(100),
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
                  state.completedSessionsToday >= 8
                      ? 'Awesome! Goal completed for today!'
                      : "Keep going! You're making great progress.",
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
            isSelected: index == _selectedEnvironmentIndex,
            onTap: () {
              setState(() {
                _selectedEnvironmentIndex = index;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDndCard(
    BuildContext context,
    FocusTimerState state,
    FocusTimerNotifier notifier,
  ) {
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
            value: state.dndEnabled,
            onChanged: (val) => notifier.toggleDnd(val),
            activeThumbColor: ColorTokens.surface,
            activeTrackColor: ColorTokens.primary,
            inactiveThumbColor: ColorTokens.outline,
            inactiveTrackColor: ColorTokens.surfaceContainerHighest,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionHistory(BuildContext context, FocusTimerState state) {
    final theme = Theme.of(context);
    final history = state.history;

    if (history.isEmpty) {
      return _buildSectionContainer(
        context: context,
        title: 'Recent Sessions',
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
          child: Text(
            'No study sessions recorded yet. Start your first session above!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: ColorTokens.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return _buildSectionContainer(
      context: context,
      title: 'Recent Sessions',
      padding: EdgeInsets.zero,
      child: Column(
        children: history.take(10).toList().asMap().entries.map((entry) {
          final index = entry.key;
          final session = entry.value;
          final IconData iconData = _getSubjectIcon(session.subject);

          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: LayoutTokens.cardPadding,
              vertical: LayoutTokens.cardPadding + 4,
            ),
            decoration: BoxDecoration(
              border: index != history.length - 1 && index != 9
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
                    iconData,
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
                        session.subject,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: ColorTokens.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${session.durationMinutes} min',
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

  IconData _getSubjectIcon(String subject) {
    final lower = subject.toLowerCase();
    if (lower.contains('math')) return Symbols.calculate;
    if (lower.contains('operating') || lower.contains('system')) return Symbols.memory;
    if (lower.contains('dbms') || lower.contains('data')) return Symbols.database;
    return Symbols.book;
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
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool showBorder;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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
