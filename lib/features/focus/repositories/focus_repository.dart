import 'dart:convert';

import 'package:college_companion/features/focus/models/focus_timer_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FocusRepository {
  static const String _historyKey = 'focus_session_history';
  static const String _dndKey = 'focus_dnd_enabled';

  Future<List<FocusSession>> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_historyKey);
    if (jsonList == null || jsonList.isEmpty) {
      // Default initial mock history so users see realistic history out of the box
      final initialHistory = [
        FocusSession(
          id: 'sess_1',
          subject: 'Mathematics',
          durationMinutes: 25,
          completedAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        FocusSession(
          id: 'sess_2',
          subject: 'Operating Systems',
          durationMinutes: 45,
          completedAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        FocusSession(
          id: 'sess_3',
          subject: 'DBMS Revision',
          durationMinutes: 25,
          completedAt: DateTime.now().subtract(const Duration(hours: 24)),
        ),
      ];
      await saveSessions(initialHistory);
      return initialHistory;
    }

    try {
      return jsonList
          .map((item) => FocusSession.fromJson(json.decode(item) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSessions(List<FocusSession> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = sessions.map((s) => json.encode(s.toJson())).toList();
    await prefs.setStringList(_historyKey, jsonList);
  }

  Future<void> addSession(FocusSession session) async {
    final current = await loadSessions();
    final updated = [session, ...current];
    await saveSessions(updated);
  }

  Future<bool> loadDndSetting() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_dndKey) ?? true;
  }

  Future<void> saveDndSetting(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dndKey, enabled);
  }
}
