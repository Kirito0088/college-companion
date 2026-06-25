/// Design Tokens: Spacing Tokens
///
/// Every margin, padding, and gap must reference one of these values.
/// Never create one-off spacing values (per 01-design-tokens.md).
library;

/// Spacing tokens following the defined spacing scale.
abstract final class SpacingTokens {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 48;
  static const double massive = 64;
}

/// Layout tokens for consistent screen-level spacing.
abstract final class LayoutTokens {
  /// Horizontal padding for screen content.
  static const double screenPadding = SpacingTokens.base;

  /// Vertical gap between sections.
  static const double sectionGap = SpacingTokens.xl;

  /// Gap between components within a section.
  static const double componentGap = SpacingTokens.md;

  /// Internal padding for cards.
  static const double cardPadding = SpacingTokens.base;

  /// Height of the bottom navigation bar.
  static const double bottomNavigationHeight = 80;
}
