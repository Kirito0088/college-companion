/// Lecture Status — Value Object
///
/// Encodes the primary + secondary attendance status into the format
/// stored in `lecture_records.status_text`:
/// - `"present"` | `"absent"` | `"cancelled"` (primary only)
/// - `"absent|holiday"` | `"cancelled|faculty_absent"` etc.
/// - `"absent|other|Family emergency"` (other + custom text, spec §5)
library;

/// An immutable value object encoding a lecture's attendance status.
class LectureStatus {
  const LectureStatus._({
    required this.primary,
    this.secondary,
    this.otherText,
  });

  /// The primary status (spec §5).
  final String primary;

  /// The optional secondary context (spec §5).
  final String? secondary;

  /// Custom text when secondary is "other" (spec §5).
  final String? otherText;

  /// Present — no secondary.
  const LectureStatus.present() : this._(primary: 'present');

  /// Absent — no secondary.
  const LectureStatus.absent() : this._(primary: 'absent');

  /// Absent with a secondary reason (e.g. "holiday", "faculty_absent",
  /// "other").
  const LectureStatus.absentWith(this.secondary, [this.otherText])
    : primary = 'absent';

  /// Cancelled — no secondary.
  const LectureStatus.cancelled() : this._(primary: 'cancelled');

  /// Cancelled with a secondary reason (e.g. "faculty_absent",
  /// "practical_cancelled", "extra_lecture", "other").
  const LectureStatus.cancelledWith(this.secondary, [this.otherText])
    : primary = 'cancelled';

  /// Present + "other" secondary with custom text.
  const LectureStatus.presentWithOther(this.otherText)
    : primary = 'present',
      secondary = 'other';

  /// Encodes the status as stored in `lecture_records.status_text`.
  String encode() {
    final buf = StringBuffer(primary);
    if (secondary != null) {
      buf.write('|$secondary');
      if (secondary == 'other' && otherText != null) {
        buf.write('|$otherText');
      }
    }
    return buf.toString();
  }

  /// Decodes a `status_text` string back to a [LectureStatus].
  factory LectureStatus.decode(String encoded) {
    final parts = encoded.split('|');
    final primary = parts[0];
    final secondary = parts.length > 1 ? parts[1] : null;
    final otherText = parts.length > 2 ? parts[2] : null;
    return LectureStatus._(
      primary: primary,
      secondary: secondary,
      otherText: otherText,
    );
  }

  @override
  String toString() => encode();
}
