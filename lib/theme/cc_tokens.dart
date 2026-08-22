/// Design Tokens: CC Tokens (reactive theme + accent extension)
///
/// ADR-011 — User-selectable theme (light/dark) and accent (jade/sand/azure).
/// [ColorTokens]/[RadiusTokens]/[TypographyTokens] are `static const` and
/// cannot vary at runtime; this [ThemeExtension] carries the semantic slots
/// that change per (Brightness, Accent) — the ones a fixed `ColorScheme`
/// slot doesn't have a home for (soft accent tints, a bespoke shadow/sheen,
/// a third "dim" neutral beyond onSurface/onSurfaceVariant).
///
/// Access via `Theme.of(context).extension<CCTokens>()!`, or the `context.cc`
/// shorthand below.
library;

import 'package:flutter/material.dart';

/// The three selectable accent colors, per the design canvas.
enum Accent { jade, sand, azure }

/// Reactive semantic tokens for the current (brightness, accent) pair.
///
/// Field values are taken directly from the design canvas's CSS custom
/// properties (`--bg`, `--pri`, etc.) — see `[data-theme]`/`[data-accent]`
/// selectors in the source `.dc.html`.
@immutable
class CCTokens extends ThemeExtension<CCTokens> {
  const CCTokens({
    required this.bg,
    required this.surf,
    required this.raise,
    required this.raise2,
    required this.line,
    required this.line2,
    required this.fg,
    required this.mut,
    required this.dim,
    required this.pri,
    required this.priFg,
    required this.priSoft,
    required this.warn,
    required this.warnSoft,
    required this.risk,
    required this.riskSoft,
    required this.shadow,
    required this.sheen,
  });

  /// Builds the dark-theme [CCTokens] for the given [accent].
  factory CCTokens.dark(Accent accent) {
    final (pri, priFg, priSoft) = _darkAccents[accent]!;
    return CCTokens(
      bg: _darkBg,
      surf: _darkSurf,
      raise: _darkRaise,
      raise2: _darkRaise2,
      line: _darkLine,
      line2: _darkLine2,
      fg: _darkFg,
      mut: _darkMut,
      dim: _darkDim,
      pri: pri,
      priFg: priFg!,
      priSoft: priSoft,
      warn: _darkWarn,
      warnSoft: _darkWarnSoft,
      risk: _darkRisk,
      riskSoft: _darkRiskSoft,
      shadow: _darkShadow,
      sheen: _darkSheen,
    );
  }

  /// Builds the light-theme [CCTokens] for the given [accent].
  factory CCTokens.light(Accent accent) {
    final (pri, priFg, priSoft) = _lightAccents[accent]!;
    return CCTokens(
      bg: _lightBg,
      surf: _lightSurf,
      raise: _lightRaise,
      raise2: _lightRaise2,
      line: _lightLine,
      line2: _lightLine2,
      fg: _lightFg,
      mut: _lightMut,
      dim: _lightDim,
      pri: pri,
      priFg: priFg ?? _lightBasePriFg,
      priSoft: priSoft,
      warn: _lightWarn,
      warnSoft: _lightWarnSoft,
      risk: _lightRisk,
      riskSoft: _lightRiskSoft,
      shadow: _lightShadow,
      sheen: _lightSheen,
    );
  }

  /// Resolves [CCTokens] for a given [brightness] and [accent].
  factory CCTokens.resolve(Brightness brightness, Accent accent) {
    return brightness == Brightness.dark
        ? CCTokens.dark(accent)
        : CCTokens.light(accent);
  }

  /// Screen background.
  final Color bg;

  /// Base raised surface (cards, sheets).
  final Color surf;

  /// First elevation step above [surf].
  final Color raise;

  /// Second elevation step above [raise] (e.g. quick-action tiles).
  final Color raise2;

  /// Hairline border — subtle dividers between surfaces.
  final Color line;

  /// Slightly stronger hairline — emphasised borders (active states).
  final Color line2;

  /// Primary foreground text.
  final Color fg;

  /// Muted foreground — supporting text.
  final Color mut;

  /// Dimmest foreground — least emphasis (timestamps, disabled-ish labels).
  final Color dim;

  /// Accent color — the current [Accent] resolved for this brightness.
  final Color pri;

  /// Foreground drawn on top of [pri] (e.g. filled button label).
  final Color priFg;

  /// Soft translucent accent tint — badges, active-state fills.
  final Color priSoft;

  /// Warning accent (approaching deadlines, at-risk attendance).
  final Color warn;

  /// Soft translucent warning tint.
  final Color warnSoft;

  /// Risk/critical accent (overdue, below safe-bunk margin).
  final Color risk;

  /// Soft translucent risk tint.
  final Color riskSoft;

  /// Soft elevated-card shadow (used sparingly — hero cards only).
  final List<BoxShadow> shadow;

  /// Subtle top-highlight overlay for raised surfaces.
  final Gradient sheen;

  /// Dark theme, accent-independent base slots.
  static const _darkBg = Color(0xFF0E1315);
  static const _darkSurf = Color(0xFF131A1C);
  static const _darkRaise = Color(0xFF182124);
  static const _darkRaise2 = Color(0xFF1F292C);
  static const _darkLine = Color.fromRGBO(255, 255, 255, 0.075);
  static const _darkLine2 = Color.fromRGBO(255, 255, 255, 0.15);
  static const _darkFg = Color(0xFFE9EEEC);
  static const _darkMut = Color(0xFF93A09C);
  static const _darkDim = Color(0xFF616C69);
  static const _darkWarn = Color(0xFFE3B274);
  static const _darkWarnSoft = Color.fromRGBO(227, 178, 116, 0.15);
  static const _darkRisk = Color(0xFFE98A80);
  static const _darkRiskSoft = Color.fromRGBO(233, 138, 128, 0.15);
  static const _darkShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.85),
      blurRadius: 44,
      spreadRadius: -22,
      offset: Offset(0, 20),
    ),
  ];
  static const _darkSheen = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.fromRGBO(255, 255, 255, 0.05),
      Color.fromRGBO(255, 255, 255, 0),
    ],
  );

  /// Light theme, accent-independent base slots.
  static const _lightBg = Color(0xFFF3F0EA);
  static const _lightSurf = Color(0xFFFFFFFF);
  static const _lightRaise = Color(0xFFFFFFFF);
  static const _lightRaise2 = Color(0xFFFAF8F3);
  static const _lightLine = Color.fromRGBO(21, 32, 30, 0.09);
  static const _lightLine2 = Color.fromRGBO(21, 32, 30, 0.18);
  static const _lightFg = Color(0xFF16201E);
  static const _lightMut = Color(0xFF65726E);
  static const _lightDim = Color(0xFF98A29E);
  static const _lightWarn = Color(0xFF9A6B1E);
  static const _lightWarnSoft = Color.fromRGBO(154, 107, 30, 0.12);
  static const _lightRisk = Color(0xFFB5473F);
  static const _lightRiskSoft = Color.fromRGBO(181, 71, 63, 0.10);
  static const _lightShadow = [
    BoxShadow(
      color: Color.fromRGBO(21, 32, 30, 0.30),
      blurRadius: 36,
      spreadRadius: -20,
      offset: Offset(0, 16),
    ),
  ];
  static const _lightSheen = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.fromRGBO(255, 255, 255, 0.7),
      Color.fromRGBO(255, 255, 255, 0),
    ],
  );

  /// Accent-specific `(pri, priFg, priSoft)` overrides. Jade is the base
  /// theme's default accent, so it needs no override.
  static const Map<Accent, (Color pri, Color? priFg, Color priSoft)>
  _darkAccents = {
    Accent.jade: (
      Color(0xFF6FCFB0),
      Color(0xFF052620),
      Color.fromRGBO(111, 207, 176, 0.15),
    ),
    Accent.sand: (
      Color(0xFFE3B274),
      Color(0xFF281904),
      Color.fromRGBO(227, 178, 116, 0.15),
    ),
    Accent.azure: (
      Color(0xFF7FB8E8),
      Color(0xFF04202F),
      Color.fromRGBO(127, 184, 232, 0.15),
    ),
  };

  static const Map<Accent, (Color pri, Color? priFg, Color priSoft)>
  _lightAccents = {
    Accent.jade: (
      Color(0xFF1C7A63),
      null, // falls back to the light theme's base priFg (#FFFFFF)
      Color.fromRGBO(28, 122, 99, 0.10),
    ),
    Accent.sand: (Color(0xFF8A5D14), null, Color.fromRGBO(138, 93, 20, 0.11)),
    Accent.azure: (Color(0xFF1F6491), null, Color.fromRGBO(31, 100, 145, 0.10)),
  };

  static const Color _lightBasePriFg = Color(0xFFFFFFFF);

  @override
  CCTokens copyWith({
    Color? bg,
    Color? surf,
    Color? raise,
    Color? raise2,
    Color? line,
    Color? line2,
    Color? fg,
    Color? mut,
    Color? dim,
    Color? pri,
    Color? priFg,
    Color? priSoft,
    Color? warn,
    Color? warnSoft,
    Color? risk,
    Color? riskSoft,
    List<BoxShadow>? shadow,
    Gradient? sheen,
  }) {
    return CCTokens(
      bg: bg ?? this.bg,
      surf: surf ?? this.surf,
      raise: raise ?? this.raise,
      raise2: raise2 ?? this.raise2,
      line: line ?? this.line,
      line2: line2 ?? this.line2,
      fg: fg ?? this.fg,
      mut: mut ?? this.mut,
      dim: dim ?? this.dim,
      pri: pri ?? this.pri,
      priFg: priFg ?? this.priFg,
      priSoft: priSoft ?? this.priSoft,
      warn: warn ?? this.warn,
      warnSoft: warnSoft ?? this.warnSoft,
      risk: risk ?? this.risk,
      riskSoft: riskSoft ?? this.riskSoft,
      shadow: shadow ?? this.shadow,
      sheen: sheen ?? this.sheen,
    );
  }

  @override
  CCTokens lerp(ThemeExtension<CCTokens>? other, double t) {
    if (other is! CCTokens) return this;
    return CCTokens(
      bg: Color.lerp(bg, other.bg, t)!,
      surf: Color.lerp(surf, other.surf, t)!,
      raise: Color.lerp(raise, other.raise, t)!,
      raise2: Color.lerp(raise2, other.raise2, t)!,
      line: Color.lerp(line, other.line, t)!,
      line2: Color.lerp(line2, other.line2, t)!,
      fg: Color.lerp(fg, other.fg, t)!,
      mut: Color.lerp(mut, other.mut, t)!,
      dim: Color.lerp(dim, other.dim, t)!,
      pri: Color.lerp(pri, other.pri, t)!,
      priFg: Color.lerp(priFg, other.priFg, t)!,
      priSoft: Color.lerp(priSoft, other.priSoft, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
      warnSoft: Color.lerp(warnSoft, other.warnSoft, t)!,
      risk: Color.lerp(risk, other.risk, t)!,
      riskSoft: Color.lerp(riskSoft, other.riskSoft, t)!,
      shadow: BoxShadow.lerpList(shadow, other.shadow, t) ?? shadow,
      sheen: Gradient.lerp(sheen, other.sheen, t) ?? sheen,
    );
  }
}

/// Shorthand access to the current [CCTokens].
extension CCTokensContext on BuildContext {
  /// The resolved [CCTokens] for the ambient [Theme].
  CCTokens get cc => Theme.of(this).extension<CCTokens>()!;
}
