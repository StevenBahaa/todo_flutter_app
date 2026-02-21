// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_colors_light.dart';

class AppTheme {
  static ThemeData darkTheme() {
    final base = ThemeData.dark(useMaterial3: true);

    final scheme = base.colorScheme.copyWith(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      background: AppColors.bg,
      onBackground: AppColors.text,
      surface: AppColors.surface,
      onSurface: AppColors.text,
      surfaceContainerHighest: AppColors.surface2,
      outline: AppColors.border,
      error: AppColors.danger,
      onError: Colors.white,
      secondary: AppColors.warning, // ✅ add
      onSecondary: Colors.black, // ✅ add (أو white حسب ذوقك)
      tertiary: AppColors.success, // ✅ add
      onTertiary: Colors.black,
    );

    return base.copyWith(
      colorScheme: scheme,

      scaffoldBackgroundColor: scheme.background,

      appBarTheme: AppBarTheme(
        backgroundColor: scheme.background,
        elevation: 0,
        centerTitle: false,
        foregroundColor: scheme.onBackground,
      ),

      textTheme: base.textTheme.apply(
        bodyColor: scheme.onBackground,
        displayColor: scheme.onBackground,
      ),

      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),

      dividerTheme: DividerThemeData(color: scheme.outline, thickness: 1),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: const CircleBorder(),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        hintStyle: TextStyle(color: scheme.onSurface.withOpacity(0.55)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        shape: const CircleBorder(),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return scheme.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(scheme.onPrimary),
        side: BorderSide(color: scheme.outline, width: 2.2),
      ),

      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.chip, // optional: keep token
        selectedColor: AppColors.primarySoft, // optional: keep token
        labelStyle: TextStyle(color: scheme.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.transparent),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
    );
  }

  static ThemeData lightTheme() {
    final base = ThemeData.light(useMaterial3: true);

    final scheme = base.colorScheme.copyWith(
      brightness: Brightness.light,
      primary: AppColorsLight.primary,
      onPrimary: Colors.white,
      background: AppColorsLight.bg,
      onBackground: AppColorsLight.text,
      surface: AppColorsLight.surface,
      onSurface: AppColorsLight.text,
      surfaceContainerHighest: AppColorsLight.surface2,
      outline: AppColorsLight.border,
      error: AppColorsLight.danger, // add danger in AppColorsLight if missing
      onError: Colors.white,
      secondary: AppColorsLight.warning, // ✅ add
      onSecondary: Colors.black, // ✅ add
      tertiary: AppColorsLight.success, // ✅ add
      onTertiary: Colors.white, // ✅ add
    );

    return base.copyWith(
      colorScheme: scheme,

      scaffoldBackgroundColor: scheme.background,

      appBarTheme: AppBarTheme(
        backgroundColor: scheme.background,
        elevation: 0,
        centerTitle: false,
        foregroundColor: scheme.onBackground,
      ),

      textTheme: base.textTheme.apply(
        bodyColor: scheme.onBackground,
        displayColor: scheme.onBackground,
      ),

      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),

      dividerTheme: DividerThemeData(color: scheme.outline, thickness: 1),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: const CircleBorder(),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        hintStyle: TextStyle(color: scheme.onSurface.withOpacity(0.55)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        shape: const CircleBorder(),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return scheme.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(scheme.onPrimary),
        side: BorderSide(color: scheme.outline, width: 2.2),
      ),

      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColorsLight.chip,
        selectedColor: AppColorsLight.primarySoft,
        labelStyle: TextStyle(color: scheme.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.transparent),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
    );
  }
}
