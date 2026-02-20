import 'package:flutter/material.dart';
import 'package:todo_list/core/theme/app_colors_light.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData darkTheme() {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: base.colorScheme.copyWith(
        brightness: Brightness.dark,
        primary: AppColors.primary,
        surface: AppColors.surface,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bg,
        elevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.text,
      ),

      textTheme: base.textTheme.apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: CircleBorder(),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface2,
        hintStyle: const TextStyle(color: AppColors.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        shape: const CircleBorder(),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.transparent;
        }),
        // checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: Color(0xFF3A4A6B), width: 2.2),
      ),

      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.chip,
        selectedColor: AppColors.primarySoft,
        labelStyle: const TextStyle(color: AppColors.text),
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

    return base.copyWith(
      scaffoldBackgroundColor: AppColorsLight.bg,
      colorScheme: base.colorScheme.copyWith(
        brightness: Brightness.light,
        primary: AppColorsLight.primary,
        surface: AppColorsLight.surface,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColorsLight.bg,
        elevation: 0,
        centerTitle: false,
        foregroundColor: AppColorsLight.text,
      ),

      textTheme: base.textTheme.apply(
        bodyColor: AppColorsLight.text,
        displayColor: AppColorsLight.text,
      ),

      cardTheme: CardThemeData(
        color: AppColorsLight.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColorsLight.border,
        thickness: 1,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColorsLight.primary,
        foregroundColor: Colors.white,
        shape: CircleBorder(),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColorsLight.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsLight.surface2,
        hintStyle: const TextStyle(color: AppColorsLight.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        shape: const CircleBorder(),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColorsLight.primary;
          return Colors.transparent;
        }),
        side: BorderSide(color: AppColorsLight.border, width: 2.2),
      ),

      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColorsLight.chip,
        selectedColor: AppColorsLight.primarySoft,
        labelStyle: const TextStyle(color: AppColorsLight.text),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.transparent),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
    );
  }
}


