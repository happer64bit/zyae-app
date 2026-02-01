import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF1565C0);
  static const Color secondaryColor = Color(0xFF00C853);
  static const Color accentColor = Color(0xFFE8F0FE);

  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color surfaceColor = Colors.white;

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textPlaceholder = Color(0xFF9E9E9E);
  static const Color borderColor = Color(0xFFE0E0E0);

  static const Color successColor = Color(0xFF2E7D32);
  static const Color warningColor = Color(0xFFEF6C00);
  static const Color errorColor = Color(0xFFC62828);

  static const Color moneyColor = Color(0xFF2E7D32);
  static const Color stockSuccessBg = Color(0xFFE8F5E9);
  static const Color stockSuccessText = Color(0xFF2E7D32);
  static const Color stockWarningBg = Color(0xFFFFF3E0);
  static const Color stockWarningText = Color(0xFFEF6C00);
  static const Color stockErrorBg = Color(0xFFFFEBEE);
  static const Color stockErrorText = Color(0xFFC62828);

  // 1. SPACING CONSTANTS
  static const double gapSmall = 8.0;
  static const double gapMedium = 16.0;
  static const double gapLarge = 24.0;

  static const double radiusCard = 16.0;
  static const double radiusButton = 12.0;

  // 2. TEXT STYLES
  static TextStyle get headerStyle => GoogleFonts.notoSansMyanmar(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.5,
    color: textPrimary,
  );

  static TextStyle get priceStyle => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: primaryColor,
  );

  static TextStyle get titleStyle => GoogleFonts.notoSansMyanmar(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: textPrimary,
  );

  static TextStyle get captionStyle => GoogleFonts.notoSansMyanmar(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.2,
    color: textSecondary,
  );

  // 3. CARD DECORATION
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: surfaceColor,
    borderRadius: BorderRadius.circular(radiusCard),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

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
        elevation: 2,
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
        fillColor: const Color(0xFFF7F9FC),
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
        hintStyle: TextStyle(
          color: textPlaceholder,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          fontFamily: fontFamily,
        ),
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
