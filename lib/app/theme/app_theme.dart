import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF004D40);
  static const Color onPrimary = Colors.white;
  static const Color primaryContainer = Color(0xFFAFEFDD);
  static const Color onPrimaryContainer = Color(0xFF00201A);

  static const Color secondary = Color(0xFF526069);
  static const Color onSecondary = Colors.white;
  static const Color secondaryContainer = Color(0xFFD3E2ED);
  static const Color onSecondaryContainer = Color(0xFF0F1D25);

  static const Color aiAccent = Color(0xFF42A5F5);
  static const Color aiSoft = Color(0xFFE3F2FD);
  
  static const Color surface = Color(0xFFF9F9F9);
  static const Color surfaceVariant = Color(0xFFEBEBEB);
  static const Color onSurface = Color(0xFF1A1C1C);
  static const Color onSurfaceVariant = Color(0xFF3F4945);
  static const Color outline = Color(0xFF707975);
  static const Color outlineVariant = Color(0xFFBFC9C4);
}

class AppTheme {
  AppTheme._();

  static const Color primary = AppColors.primary;
  static const Color onPrimary = AppColors.onPrimary;
  static const Color primaryContainer = AppColors.primaryContainer;
  static const Color onPrimaryContainer = AppColors.onPrimaryContainer;
  static const Color secondary = AppColors.secondary;
  static const Color onSecondary = AppColors.onSecondary;
  static const Color secondaryContainer = AppColors.secondaryContainer;
  static const Color onSecondaryContainer = AppColors.onSecondaryContainer;
  static const Color aiAccent = AppColors.aiAccent;
  static const Color aiSoft = AppColors.aiSoft;
  static const Color surface = AppColors.surface;
  static const Color surfaceVariant = AppColors.surfaceVariant;
  static const Color onSurface = AppColors.onSurface;
  static const Color onSurfaceVariant = AppColors.onSurfaceVariant;
  static const Color outline = AppColors.outline;
  static const Color outlineVariant = AppColors.outlineVariant;

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
    ),
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.publicSans(
        fontWeight: FontWeight.bold,
        color: AppColors.onSurface,
      ),
      displayMedium: GoogleFonts.publicSans(
        fontWeight: FontWeight.bold,
        color: AppColors.onSurface,
      ),
      displaySmall: GoogleFonts.publicSans(
        fontWeight: FontWeight.bold,
        color: AppColors.onSurface,
      ),
      headlineMedium: GoogleFonts.publicSans(
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.primary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    ),
  );
}
