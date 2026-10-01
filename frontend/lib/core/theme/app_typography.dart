import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static final TextTheme textTheme = GoogleFonts.interTextTheme().copyWith(
    displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: -0.5),
    displayMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: -0.5),
    displaySmall: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary),

    headlineLarge: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    headlineMedium: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    headlineSmall: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),

    titleLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    titleMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    titleSmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),

    bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.textPrimary),
    bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textPrimary),
    bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.normal, color: AppColors.textSecondary),

    labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
    labelSmall: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
  );

  // Specialized styles
  static final TextStyle currencyLarge = GoogleFonts.robotoMono(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary);
  static final TextStyle currencyMedium = GoogleFonts.robotoMono(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static final TextStyle currencySmall = GoogleFonts.robotoMono(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary);

  static final TextStyle tableHeader = GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5);
}
