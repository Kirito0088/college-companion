import 'dart:convert';

import 'package:college_companion/features/focus/models/focus_timer_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FocusRepository {
  static const String _historyKey = 'focus_session_history';
  static const String _dndKey = 'focus_dnd_enabled';

  /// Ids of the sample sessions earlier builds wrote into a fresh install's
  /// history (#36). Real sessions are keyed by a millisecond timestamp, so
  /// these cannot collide with anything a student recorded.
  static const Set<String> _seededSampleIds = {'sess_1', 'sess_2', 'sess_3'};

  Future<List<FocusSession>> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_historyKey);
    if (jsonList == null || jsonList.isEmpty) return [];

    final List<FocusSession> sessions;
    try {
      sessions = jsonList
          .map(
            (item) => FocusSession.fromJson(
              json.decode(item) as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }

    final real = sessions
        .where((s) => !_seededSampleIds.contains(s.id))
        .toList();
    if (real.length != sessions.length) await saveSessions(real);
    return real;
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
