import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/calendar/providers/calendar_provider.dart';
import 'package:college_companion/features/calendar/widgets/agenda_card.dart';
import 'package:college_companion/features/calendar/widgets/calendar_month_view.dart';
import 'package:college_companion/routing/app_router.dart';
import 'package:college_companion/shared/widgets/empty_states/cc_empty_states.dart';
import 'package:college_companion/shared/widgets/errors/cc_error_state.dart';
import 'package:college_companion/shared/widgets/loading/cc_skeletons.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  int _selectedDate = DateTime.now().day;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  Map<int, List<CalendarEventEntity>> _buildEventsMap(
    List<CalendarEventEntity> entities,
  ) {
    final map = <int, List<CalendarEventEntity>>{};
    for (final entity in entities) {
      final startDt = DateTime.tryParse(entity.startDate);
      if (startDt != null &&
          startDt.month == _selectedMonth.month &&
          startDt.year == _selectedMonth.year) {
        map.putIfAbsent(startDt.day, () => []).add(entity);
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;
    final authState = ref.watch(authStateProvider);
    final userId =
        authState is AuthAuthenticated && authState.user.uid.isNotEmpty
        ? authState.user.uid
        : 'default_user';

    final eventsAsync = ref.watch(calendarEventsStreamProvider(userId));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, theme, cc),
            Expanded(
              child: eventsAsync.when(
                data: (entities) {
                  final eventsMap = _buildEventsMap(entities);
                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      left: LayoutTokens.screenPadding,
                      right: LayoutTokens.screenPadding,
                      top: SpacingTokens.md,
                      bottom: SpacingTokens.huge,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CalendarMonthView(
                          selectedDate: _selectedDate,
                          events: eventsMap,
                          onDateSelected: (date) {
                            setState(() {
                              _selectedDate = date;
                            });
                          },
                        ),
                        const SizedBox(height: SpacingTokens.xxl),
                        _buildAgendaSection(context, theme, cc, eventsMap),
                        const SizedBox(height: 100),
                      ],
                    ),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: LayoutTokens.screenPadding,
                    vertical: SpacingTokens.md,
                  ),
                  child: SkeletonList(),
                ),
                error: (err, stack) => Center(
                  child: CcErrorState(
                    error: err,
                    onRetry: () {
                      ref.invalidate(calendarEventsStreamProvider(userId));
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(RoutePaths.addEditEvent);
        },
        backgroundColor: cc.pri,
        foregroundColor: cc.priFg,
        elevation: 2,
        child: const Icon(Symbols.add),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, CCTokens cc) {
    final monthLabel =
        '${_monthNames[_selectedMonth.month - 1]} ${_selectedMonth.year}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        LayoutTokens.screenPadding,
        SpacingTokens.xl,
        LayoutTokens.screenPadding,
        SpacingTokens.lg,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calendar',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cc.fg,
                  ),
                ),
                const SizedBox(height: SpacingTokens.xs),
                InkWell(
                  onTap: () {},
                  borderRadius: RadiusTokens.borderRadiusSm,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: SpacingTokens.xxs,
                      horizontal: SpacingTokens.xxs,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            monthLabel,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: cc.pri,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: SpacingTokens.xxs),
                        Icon(Symbols.arrow_drop_down, size: 24, color: cc.pri),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedMonth = DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                    );
                    _selectedDate = DateTime.now().day;
                  });
                },
                icon: const Icon(Symbols.today, size: 24),
                color: cc.mut,
                tooltip: 'Today',
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedMonth = DateTime(
                      _selectedMonth.year,
                      _selectedMonth.month - 1,
                    );
                  });
                },
                icon: const Icon(Symbols.chevron_left, size: 28),
                color: cc.fg,
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedMonth = DateTime(
                      _selectedMonth.year,
                      _selectedMonth.month + 1,
                    );
                  });
                },
                icon: const Icon(Symbols.chevron_right, size: 28),
                color: cc.fg,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgendaSection(
    BuildContext context,
    ThemeData theme,
    CCTokens cc,
    Map<int, List<CalendarEventEntity>> eventsMap,
  ) {
    final eventsForSelected = eventsMap[_selectedDate] ?? [];

    Widget content;
    if (eventsForSelected.isEmpty) {
      content = const EmptyCalendar();
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: eventsForSelected
            .map(
              (event) => AgendaCard(
                event: event,
                onTap: () {
                  context.push('/calendar/event-details/${event.id}');
                },
              ),
            )
            .toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Agenda',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cc.fg,
                letterSpacing: 0.5,
              ),
            ),
            if (eventsForSelected.isNotEmpty)
              Text(
                '${eventsForSelected.length} event${eventsForSelected.length == 1 ? '' : 's'}',
                style: theme.textTheme.labelMedium?.copyWith(color: cc.mut),
              ),
          ],
        ),
        const SizedBox(height: SpacingTokens.md),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: KeyedSubtree(
            key: ValueKey<String>('$_selectedDate-${eventsForSelected.length}'),
            child: content,
          ),
        ),
      ],
    );
  }
}
