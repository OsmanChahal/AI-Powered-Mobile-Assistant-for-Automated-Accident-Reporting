import 'package:flutter/material.dart';

class AppColors {
  // Primary blue
  static const blue50 = Color(0xFFE6F1FB);
  static const blue200 = Color(0xFF85B7EB);
  static const blue400 = Color(0xFF378ADD);
  static const blue600 = Color(0xFF185FA5);
  static const blue800 = Color(0xFF0C447C);

  // Green (low severity)
  static const green50 = Color(0xFFEAF3DE);
  static const green400 = Color(0xFF639922);
  static const green600 = Color(0xFF3B6D11);

  // Amber (medium severity)
  static const amber50 = Color(0xFFFAEEDA);
  static const amber200 = Color(0xFFFAC775);
  static const amber400 = Color(0xFFBA7517);
  static const amber600 = Color(0xFF854F0B);

  // Red (high severity)
  static const red50 = Color(0xFFFCEBEB);
  static const red400 = Color(0xFFE24B4A);
  static const red600 = Color(0xFFA32D2D);

  // Teal (accent)
  static const teal50 = Color(0xFFE1F5EE);
  static const teal400 = Color(0xFF1D9E75);

  // Neutrals
  static const surface = Color(0xFFF5F5F5);
  static const border = Color(0xFFE0E0E0);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF666666);
  static const textTertiary = Color(0xFF999999);
  static const cameraBg = Color(0xFF1A1A1A);
  static const cameraOverlay = Color(0xFF111111);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.blue600,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        fontFamily: 'SF Pro Display',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary),
          headlineMedium: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary),
          bodyLarge: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary),
          bodyMedium: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary),
          bodySmall: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.textTertiary),
        ),
      );
}
