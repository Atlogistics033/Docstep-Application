import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors (Aapki choice ke mutabiq)
  static const Color primary = Color(
    0xFF0D9488,
  ); // Soft Teal (Main Theme Color)
  static const Color primaryLight = Color(0xFF2DD4BF); // Light Teal
  static const Color primaryDark = Color(0xFF115E59); // Dark Teal

  static const Color secondary = Color(
    0xFF1E3A8A,
  ); // Navy Blue (Buttons aur Primary accents ke liye)
  static const Color accent = Color(0xFF818CF8); // Lavender (Soft Highlights)

  static const Color backgroundLight = Color(
    0xFFF5F3FF,
  ); // Lavender-tinted Soft White Background
  static const Color surfaceLight = Colors.white; // Pure White
  static const Color borderLight = Color(0xFFE0E7FF); // Lavender Border

  static const Color textDark = Color(
    0xFF0F172A,
  ); // Navy-Black Text for Headings
  static const Color textMedium = Color(0xFF334155); // Medium Slate for Body
  static const Color textLight = Color(0xFF64748B); // Light Grey Text

  // Gradients (Soft Teal to Navy & Lavender combinations)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF0F766E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFEEF2F6)], // White to soft Lavender-white
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Card Decorations
  static BoxDecoration cardDecoration({
    Color color = Colors.white,
    double radius = 16.0,
    bool showBorder = true,
    bool showShadow = true,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: showBorder ? Border.all(color: borderLight, width: 1.0) : null,
      boxShadow: showShadow
          ? [
              BoxShadow(
                color: const Color(0xFF1E3A8A).withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: const Color(0xFF1E3A8A).withValues(alpha: 0.02),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ]
          : null,
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        tertiary: accent,
        surface: surfaceLight,
      ),
      scaffoldBackgroundColor: backgroundLight,

      // Typography
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textDark,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textMedium,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textLight,
        ),
      ),

      // Input Decoration (Text fields)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        labelStyle: GoogleFonts.inter(color: textMedium, fontSize: 14),
        hintStyle: GoogleFonts.inter(color: textLight, fontSize: 14),
      ),

      // Buttons Theme (Soft Teal Buttons with White Text)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary, // Soft Teal Button
          foregroundColor: Colors.white, // White Text
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      cardTheme: const CardThemeData(
        color: surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: borderLight, width: 1),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        shape: const Border(bottom: BorderSide(color: borderLight, width: 1)),
      ),
    );
  }
}
