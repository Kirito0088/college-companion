/// BuildContext Extensions
///
/// Convenience extensions to reduce boilerplate when accessing
/// theme, color scheme, and text theme from [BuildContext].
library;

import 'package:flutter/material.dart';

/// Extensions on [BuildContext] for easy theme access.
extension ContextExtensions on BuildContext {
  /// The current [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// The current [ColorScheme].
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// The current [TextTheme].
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// The current [MediaQueryData].
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// The current screen size.
  Size get screenSize => MediaQuery.sizeOf(this);
}
