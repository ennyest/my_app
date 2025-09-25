import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6B46C1); // Purple
  static const Color primaryLight = Color(0xFF9F7AEA);
  static const Color primaryDark = Color(0xFF553C9A);
  static const Color onPrimary = Colors.white;

  // Secondary Colors
  static const Color secondary = Color(0xFFF59E0B); // Amber
  static const Color secondaryLight = Color(0xFFFCD34D);
  static const Color secondaryDark = Color(0xFFD97706);
  static const Color onSecondary = Colors.white;

  // Accent Colors
  static const Color accent = Color(0xFFEC4899); // Pink
  static const Color accentLight = Color(0xFFF472B6);
  static const Color accentDark = Color(0xFFDB2777);

  // Neutral Colors - Light Theme
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF3F4F6);
  static const Color outline = Color(0xFFE5E7EB);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Neutral Colors - Dark Theme
  static const Color darkBackground = Color(0xFF0F0F0F);
  static const Color darkSurface = Color(0xFF1F1F1F);
  static const Color darkSurfaceVariant = Color(0xFF2D2D2D);
  static const Color darkOutline = Color(0xFF404040);
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFFD1D5DB);
  static const Color darkTextTertiary = Color(0xFF9CA3AF);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);
  static const Color onSuccess = Colors.white;

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFCD34D);
  static const Color warningDark = Color(0xFFD97706);
  static const Color onWarning = Colors.white;

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);
  static const Color onError = Colors.white;

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);
  static const Color onInfo = Colors.white;

  // Hair Color Palette
  static const Color blackHair = Color(0xFF1F2937);
  static const Color brownHair = Color(0xFF8B4513);
  static const Color blondeHair = Color(0xFFF4E4BC);
  static const Color redHair = Color(0xFFDC2626);
  static const Color grayHair = Color(0xFF6B7280);
  static const Color whiteHair = Color(0xFFF9FAFB);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryLight],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );

  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x4D000000);

  // Overlay Colors
  static const Color overlayLight = Color(0x1AFFFFFF);
  static const Color overlayMedium = Color(0x33FFFFFF);
  static const Color overlayDark = Color(0x4DFFFFFF);

  // Hair Type Colors (for UI indicators)
  static const Color curlyHair = Color(0xFF8B5CF6);
  static const Color straightHair = Color(0xFF3B82F6);
  static const Color wavyHair = Color(0xFF06B6D4);
  static const Color kinkyHair = Color(0xFFEF4444);

  // Face Shape Colors (for UI indicators)
  static const Color ovalFace = Color(0xFF10B981);
  static const Color roundFace = Color(0xFFF59E0B);
  static const Color squareFace = Color(0xFF8B5CF6);
  static const Color heartFace = Color(0xFFEC4899);
  static const Color diamondFace = Color(0xFF06B6D4);

  // Difficulty Level Colors
  static const Color easyDifficulty = Color(0xFF10B981);
  static const Color mediumDifficulty = Color(0xFFF59E0B);
  static const Color hardDifficulty = Color(0xFFEF4444);

  // AR/3D Colors
  static const Color arOverlay = Color(0x80000000);
  static const Color arHighlight = Color(0xFFFFD700);
  static const Color arGrid = Color(0x40FFFFFF);

  // Social Media Colors
  static const Color instagram = Color(0xFFE4405F);
  static const Color facebook = Color(0xFF1877F2);
  static const Color twitter = Color(0xFF1DA1F2);
  static const Color tiktok = Color(0xFF000000);
  static const Color pinterest = Color(0xFFBD081C);
}
