/// Unit tests for the dashboard's Next Break derivation (#38).
///
/// The tile used to read a literal 'In 2 hrs' whatever the day held,
/// including days with no classes at all.
library;

import 'package:college_companion/features/dashboard/models/next_break.dart';
import 'package:flutter_test/flutter_test.dart';

ScheduledBlock _block(int startH, int startM, int endH, int endM) => (
  start: DateTime(2026, 10, 2, startH, startM),
  end: DateTime(2026, 10, 2, endH, endM),
);

DateTime _at(int h, int m) => DateTime(2026, 10, 2, h, m);

void main() {
  group('describeNextBreak', () {
    test('a day with no classes claims no break time', () {
      expect(describeNextBreak(const [], _at(10, 0)), 'No classes');
    });

    test('before the first class, the student is on a break now', () {
      final today = [_block(9, 0, 10, 0)];
      expect(describeNextBreak(today, _at(8, 0)), 'Now');
    });

    test('between classes, the student is on a break now', () {
      final today = [_block(9, 0, 10, 0), _block(11, 0, 12, 0)];
      expect(describeNextBreak(today, _at(10, 30)), 'Now');
    });

    test('during a class, counts down to its end', () {
      final today = [_block(9, 0, 10, 0)];
      expect(describeNextBreak(today, _at(9, 35)), 'In 25 min');
    });

    test('back-to-back classes form one block with no break between', () {
      final today = [
        _block(9, 0, 10, 0),
        _block(10, 0, 11, 0),
        _block(11, 5, 12, 0), // 5-min changeover is not a break
        _block(13, 0, 14, 0),
      ];
      expect(describeNextBreak(today, _at(9, 30)), 'In 2h 30m');
    });

    test('formats whole hours', () {
      expect(describeNextBreak([_block(9, 0, 11, 0)], _at(9, 0)), 'In 2 hrs');
      expect(describeNextBreak([_block(9, 0, 10, 0)], _at(9, 0)), 'In 1 hr');
    });

    test('after the last class, the day is done', () {
      final today = [_block(9, 0, 10, 0)];
      expect(describeNextBreak(today, _at(15, 0)), 'Done today');
    });

    test('ignores input order', () {
      final today = [_block(10, 0, 11, 0), _block(9, 0, 10, 0)];
      expect(describeNextBreak(today, _at(9, 30)), 'In 1h 30m');
    });
  });
}
