import 'package:college_companion/features/calendar/models/mock_event.dart';
import 'package:college_companion/features/calendar/widgets/agenda_card.dart';
import 'package:college_companion/features/calendar/widgets/calendar_month_view.dart';
import 'package:college_companion/routing/app_router.dart';
import 'package:college_companion/shared/models/mock_ui_state.dart';
import 'package:college_companion/shared/widgets/empty_states/cc_empty_states.dart';
import 'package:college_companion/shared/widgets/errors/cc_errors.dart';
import 'package:college_companion/shared/widgets/loading/cc_skeletons.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _selectedDate = 13; // Mock today
  MockUiState _uiState = MockUiState.success;

  // Mock events
  final List<MockEvent> _allEvents = [
    MockEvent(
      id: '1',
      title: 'Midterm Physics',
      type: EventType.exam,
      date: DateTime(2025, 5, 14),
      time: '10:00 AM - 12:00 PM',
      subject: 'Physics 101',
      location: 'Room 304, Science Building',
    ),
    MockEvent(
      id: '2',
      title: 'Lab Report Due',
      type: EventType.assignment,
      date: DateTime(2025, 5, 14),
      time: '11:59 PM',
      subject: 'Physics 101',
    ),
    MockEvent(
      id: '3',
      title: 'Team Meeting',
      type: EventType.academic,
      date: DateTime(2025, 5, 16),
      time: '2:00 PM - 3:00 PM',
    ),
    MockEvent(
      id: '4',
      title: 'CS Guest Lecture',
      type: EventType.academic,
      date: DateTime(2025, 5, 20),
      time: '4:00 PM',
      subject: 'Computer Science',
    ),
    MockEvent(
      id: '5',
      title: 'Database Project',
      type: EventType.assignment,
      date: DateTime(2025, 5, 20),
      time: '11:59 PM',
      subject: 'DBMS',
    ),
    MockEvent(
      id: '6',
      title: 'Dentist Appointment',
      type: EventType.personal,
      date: DateTime(2025, 5, 28),
      time: '9:00 AM',
    ),
  ];

  Map<int, List<MockEvent>> get _events {
    final map = <int, List<MockEvent>>{};
    for (final event in _allEvents) {
      if (event.date.month == 5 && event.date.year == 2025) {
        map.putIfAbsent(event.date.day, () => []).add(event);
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: LayoutTokens.screenPadding,
                  right: LayoutTokens.screenPadding,
                  top: SpacingTokens.md,
                  bottom: SpacingTokens.huge, // Space for FAB
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CalendarMonthView(
                      selectedDate: _selectedDate,
                      events: _events,
                      onDateSelected: (date) {
                        setState(() {
                          _selectedDate = date;
                        });
                      },
                    ),
                    const SizedBox(height: SpacingTokens.xxl),
                    _buildAgendaSection(theme),
                    const SizedBox(height: 100), // Extra FAB space
                  ],
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
        backgroundColor: ColorTokens.primary,
        foregroundColor: ColorTokens.onPrimary,
        elevation: 2,
        child: const Icon(Symbols.add),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
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
                    color: ColorTokens.onSurface,
                  ),
                ),
                const SizedBox(height: SpacingTokens.sm),
                InkWell(
                  onTap: () {}, // Future: open month picker
                  borderRadius: RadiusTokens.borderRadiusSm,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: SpacingTokens.xxs,
                      horizontal: SpacingTokens.xxs,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'May 2025',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: ColorTokens.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: SpacingTokens.xxs),
                        const Icon(
                          Symbols.arrow_drop_down,
                          size: 24,
                          color: ColorTokens.primary,
                        ),
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
                    _selectedDate = 13;
                  });
                },
                icon: const Icon(Symbols.today, size: 24),
                color: ColorTokens.onSurfaceVariant,
                tooltip: 'Today',
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Symbols.chevron_left, size: 28),
                color: ColorTokens.onSurface,
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Symbols.chevron_right, size: 28),
                color: ColorTokens.onSurface,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgendaSection(ThemeData theme) {
    final eventsForSelected = _events[_selectedDate] ?? [];

    Widget content;
    switch (_uiState) {
      case MockUiState.loading:
        content = const SkeletonList();
        break;
      case MockUiState.empty:
        content = const EmptyCalendar();
        break;
      case MockUiState.error:
        content = NetworkErrorWidget(
          onRetry: () {
            setState(() {
              _uiState = MockUiState.loading;
              Future.delayed(
                const Duration(seconds: 1),
                () => setState(() => _uiState = MockUiState.success),
              );
            });
          },
        );
        break;
      case MockUiState.success:
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
                      context.push(RoutePaths.eventDetails);
                    },
                  ),
                )
                .toList(),
          );
        }
        break;
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
                color: ColorTokens.onSurface,
                letterSpacing: 0.5,
              ),
            ),
            if (eventsForSelected.isNotEmpty && _uiState == MockUiState.success)
              Text(
                '${eventsForSelected.length} event${eventsForSelected.length == 1 ? '' : 's'}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: ColorTokens.onSurfaceVariant,
                ),
              ),
          ],
        ),
        const SizedBox(height: SpacingTokens.md),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: KeyedSubtree(
            key: ValueKey<String>('$_selectedDate-${_uiState.name}'),
            child: content,
          ),
        ),
      ],
    );
  }
}
