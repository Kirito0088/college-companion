/// Bunk Calculator Domain Service
///
/// Implements mathematical calculations for safe bunks, attendance deficit recovery,
/// and attendance status classification.
library;

/// Categorization of attendance standing.
enum AttendanceStatus {
  /// Attendance is at or above the target threshold (>= 75.0% by default).
  onTrack,

  /// Attendance has dropped below target but is above critical threshold (50.0% to 74.9%).
  warning,

  /// Attendance is in a critical deficit state (< 50.0%).
  critical,
}

/// Holds the output metrics of a bunk calculation.
class BunkCalculationResult {
  const BunkCalculationResult({
    required this.attended,
    required this.total,
    required this.targetPercentage,
    required this.currentPercentage,
    required this.safeBunks,
    required this.classesToAttend,
    required this.status,
  });

  /// Total number of classes attended (present).
  final int attended;

  /// Total number of conducted classes (present + absent).
  final int total;

  /// Target attendance percentage threshold (e.g. 75.0%).
  final double targetPercentage;

  /// Current calculated attendance percentage.
  final double currentPercentage;

  /// Number of upcoming classes that can be safely missed while maintaining >= target percentage.
  final int safeBunks;

  /// Number of consecutive upcoming classes that must be attended to reach >= target percentage.
  final int classesToAttend;

  /// Attendance status classification.
  final AttendanceStatus status;

  /// Convenience getter checking if student is currently on track or has safe bunks.
  bool get isSafe =>
      total == 0 || safeBunks > 0 || currentPercentage >= targetPercentage;

  /// Empathetic, quiet confidence microcopy describing the attendance status.
  String get statusMessage {
    if (total == 0) {
      return 'No classes recorded yet.';
    }
    if (currentPercentage >= targetPercentage) {
      if (safeBunks > 0) {
        return 'You can safely miss $safeBunks ${safeBunks == 1 ? 'class' : 'classes'} without falling below ${targetPercentage.round()}%.';
      }
      return 'You are on target. Keep attending regularly.';
    } else {
      return 'Attend the next $classesToAttend ${classesToAttend == 1 ? 'class' : 'classes'} consecutively to get back to ${targetPercentage.round()}%.';
    }
  }
}

/// Pure domain service calculating attendance safety margins and catch-up requirements.
class BunkCalculator {
  /// Default institutional attendance threshold.
  static const double defaultTargetPercentage = 75.0;

  /// Calculates bunk metrics from attended and total conducted lectures.
  ///
  /// Mathematical formulas:
  /// - When current percentage $\ge \text{targetPercentage}$:
  ///   $$\text{safeBunks} = \left\lfloor \frac{(\text{attended} \times 100) - (\text{targetPercentage} \times \text{total})}{\text{targetPercentage}} \right\rfloor$$
  /// - When current percentage $< \text{targetPercentage}$:
  ///   $$\text{classesToAttend} = \left\lceil \frac{(\text{targetPercentage} \times \text{total}) - (\text{attended} \times 100)}{100 - \text{targetPercentage}} \right\rceil$$
  static BunkCalculationResult calculate({
    required int attended,
    required int total,
    double targetPercentage = defaultTargetPercentage,
  }) {
    if (total <= 0) {
      return BunkCalculationResult(
        attended: attended,
        total: total,
        targetPercentage: targetPercentage,
        currentPercentage: 0.0,
        safeBunks: 0,
        classesToAttend: 0,
        status: AttendanceStatus.onTrack,
      );
    }

    final double currentPct = (attended / total) * 100.0;

    AttendanceStatus status;
    if (currentPct >= targetPercentage) {
      status = AttendanceStatus.onTrack;
    } else if (currentPct >= 50.0) {
      status = AttendanceStatus.warning;
    } else {
      status = AttendanceStatus.critical;
    }

    if (currentPct >= targetPercentage) {
      final double rawBunks =
          ((attended * 100.0) - (targetPercentage * total)) / targetPercentage;
      final int safeBunks = rawBunks.floor();

      return BunkCalculationResult(
        attended: attended,
        total: total,
        targetPercentage: targetPercentage,
        currentPercentage: currentPct,
        safeBunks: safeBunks < 0 ? 0 : safeBunks,
        classesToAttend: 0,
        status: status,
      );
    } else {
      final double rawToAttend =
          ((targetPercentage * total) - (attended * 100.0)) /
          (100.0 - targetPercentage);
      final int toAttend = rawToAttend.ceil();

      return BunkCalculationResult(
        attended: attended,
        total: total,
        targetPercentage: targetPercentage,
        currentPercentage: currentPct,
        safeBunks: 0,
        classesToAttend: toAttend < 0 ? 0 : toAttend,
        status: status,
      );
    }
  }
}
