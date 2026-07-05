import 'package:college_companion/shared/widgets/cc_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class EmptyAssignments extends StatelessWidget {
  const EmptyAssignments({super.key});

  @override
  Widget build(BuildContext context) {
    return const CCEmptyState(
      icon: Symbols.assignment_turned_in,
      title: 'No assignments yet',
      subtitle:
          'You have no upcoming assignments. Tap the + button to add one.',
    );
  }
}

class EmptyCalendar extends StatelessWidget {
  const EmptyCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return const CCEmptyState(
      icon: Symbols.event_busy,
      title: 'No events scheduled',
      subtitle: 'You have no events for this day. Enjoy your free time!',
    );
  }
}

class EmptyResources extends StatelessWidget {
  const EmptyResources({super.key});

  @override
  Widget build(BuildContext context) {
    return const CCEmptyState(
      icon: Symbols.folder_open,
      title: 'No resources found',
      subtitle: 'There are no files or links added for this subject.',
    );
  }
}

class EmptyNotifications extends StatelessWidget {
  const EmptyNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    return const CCEmptyState(
      icon: Symbols.notifications_off,
      title: 'No notifications',
      subtitle: 'You\'re all caught up! There are no new alerts.',
    );
  }
}

class EmptySearch extends StatelessWidget {
  const EmptySearch({super.key});

  @override
  Widget build(BuildContext context) {
    return const CCEmptyState(
      icon: Symbols.search_off,
      title: 'No results found',
      subtitle:
          'Try adjusting your search filters or trying a different keyword.',
    );
  }
}

class EmptySubjects extends StatelessWidget {
  const EmptySubjects({super.key});

  @override
  Widget build(BuildContext context) {
    return const CCEmptyState(
      icon: Symbols.menu_book,
      title: 'No subjects added',
      subtitle: 'You haven\'t added any subjects to this semester yet.',
    );
  }
}
