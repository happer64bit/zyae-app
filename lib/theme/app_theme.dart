import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = CupertinoColors.activeBlue; // Orange from screenshot
  static const Color backgroundColor = Color(0xFFF8F9FA); // Light grey background
  static const Color surfaceColor = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
  
  static const Color successColor = Color(0xFF2E7D32);
  static const Color successBg = Color(0xFFE8F5E9);
  
  static const Color warningColor = Color(0xFFEF6C00);
  static const Color warningBg = Color(0xFFFFF3E0);
  
  static const Color errorColor = Color(0xFFC62828);
  static const Color errorBg = Color(0xFFFFEBEE);

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
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFEEEEEE)),
        ),
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
