import 'package:flutter/material.dart';

extension ThemeX on BuildContext {
  ColorScheme get scheme => Theme.of(this).colorScheme;

  /// Background
  Color get bg => scheme.background;

  /// Main text
  Color get text => scheme.onBackground;

  /// Muted text (secondary text)
  Color get textMuted => scheme.onSurface.withOpacity(0.55);

  /// Surfaces (cards / sheets)
  Color get surface => scheme.surface;

  /// Borders / dividers
  Color get border => scheme.outline;

  /// Brand primary
  Color get primary => scheme.primary;

  /// Error / danger
  Color get danger => scheme.error;

  Color get warning => scheme.secondary;
  
  Color get success => scheme.tertiary;
}
