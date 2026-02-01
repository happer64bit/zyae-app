import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Minimalist Monochromatic Palette
  static const Color primaryColor = Color(0xFF000000); // Pure Black
  static const Color secondaryColor = Color(0xFF404040); // Dark Gray
  static const Color accentColor = Color(0xFFF5F5F5); // Light Gray for backgrounds
  
  static const Color backgroundColor = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceColor = Color(0xFFFFFFFF); // Pure White
  
  static const Color textPrimary = Color(0xFF000000); // Black
  static const Color textSecondary = Color(0xFF757575); // Gray 600
  static const Color borderColor = Color(0xFFE0E0E0); // Light Gray Border
  
  // Functional Colors (kept for utility but muted)
  static const Color successColor = Color(0xFF10B981); 
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);

  static ThemeData getTheme(Locale locale) {
    final isBurmese = locale.languageCode == 'my';
    final fontFamily = isBurmese 
        ? GoogleFonts.notoSansMyanmar().fontFamily 
        : GoogleFonts.poppins().fontFamily;
    
    final textTheme = isBurmese
        ? GoogleFonts.notoSansMyanmarTextTheme()
        : GoogleFonts.poppinsTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: fontFamily,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderColor),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: fontFamily,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: TextStyle(color: textSecondary, fontFamily: fontFamily),
        hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.7), fontFamily: fontFamily),
      ),
      iconTheme: const IconThemeData(
        color: textPrimary,
        size: 24,
      ),
      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 1,
      ),
      fontFamily: fontFamily,
      textTheme: textTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
        fontFamily: fontFamily,
      ),
    );
  }
}
