import 'package:flutter/material.dart';
import 'package:kyodex/core/constants/app_constants.dart';

class AppTheme {
  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppConstants.bgPrimary,
    cardColor: AppConstants.bgCard,
    colorScheme: const ColorScheme.dark(
      primary: AppConstants.accentRed,
      surface: AppConstants.bgCard,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppConstants.bgPrimary,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: AppConstants.bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
    ),
  );
}
