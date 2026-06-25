/// Design Tokens: Motion Tokens
///
/// Animation durations and curves following Material Design motion.
/// Do not hardcode durations (per 01-design-tokens.md, 06-motion.md).
library;

import 'package:flutter/animation.dart';

/// Animation duration tokens.
abstract final class MotionTokens {
  /// Instant — no perceptible delay.
  static const Duration instant = Duration(milliseconds: 100);

  /// Fast — quick feedback animations.
  static const Duration fast = Duration(milliseconds: 200);

  /// Normal — standard transitions.
  static const Duration normal = Duration(milliseconds: 300);

  /// Slow — emphasised transitions.
  static const Duration slow = Duration(milliseconds: 500);
}

/// Animation curve tokens following Material Design motion.
abstract final class CurveTokens {
  static const Curve standard = Curves.easeInOutCubicEmphasized;
  static const Curve decelerate = Curves.easeOutCubic;
  static const Curve accelerate = Curves.easeInCubic;
  static const Curve linear = Curves.linear;
}
