import 'package:flutter/material.dart';

class AppColors {
  // ── Primary Colors (Dark Theme) ──────────────────────────────────────
  static const Color darkBackground = Color(0xFF1A1428); // Dark Purple/Black
  static const Color darkScaffold = Color(0xFF201C32);
  static const Color darkCard = Color(0xFF2A1F3D);

  // ── Primary Brand Colors ─────────────────────────────────────────────
  static const Color primaryPurple = Color(0xFF7B5BA8); // Main Purple
  static const Color primaryDeep = Color(0xFF5A3D7C); // Deeper Purple
  static const Color primaryLight = Color(0xFF9B7FC4); // Lighter Purple

  // ── Accent Colors ───────────────────────────────────────────────────
  static const Color accentYellow = Color(0xFFF4D35E); // Bright Yellow
  static const Color accentGold = Color(0xFFDBA82E);

  // ── Status Colors ───────────────────────────────────────────────────
  static const Color successGreen = Color(0xFF2ECC71); // Success
  static const Color errorRed = Color(0xFFE74C3C); // Error
  static const Color warningOrange = Color(0xFFF39C12); // Warning
  static const Color infoBlue = Color(0xFF3498DB); // Info

  // ── Gradient Colors (Ekspor Laporan, Insight, etc) ──────────────────
  static const Color gradientBlueStart = Color(0xFF4A7BD6);
  static const Color gradientBlueEnd = Color(0xFF2A4B9E);

  static const Color gradientPurpleStart = Color(0xFF9B7FC4);
  static const Color gradientPurpleEnd = Color(0xFF6B5AA2);

  static const Color gradientRedStart = Color(0xFFE74C3C);
  static const Color gradientRedEnd = Color(0xFFC0392B);

  static const Color gradientYellowStart = Color(0xFFF4D35E);
  static const Color gradientYellowEnd = Color(0xFFDBA82E);

  static const Color gradientCyanStart = Color(0xFF1ABC9C);
  static const Color gradientCyanEnd = Color(0xFF16A085);

  // ── Text Colors ──────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF); // White
  static const Color textSecondary = Color(0xFFB0A8C3); // Muted Purple
  static const Color textTertiary = Color(0xFF8B7FA8); // More Muted
  static const Color textDark = Color(0xFF2A1F3D); // Dark Blue

  // ── UI Elements ──────────────────────────────────────────────────────
  static const Color divider = Color(0xFF3A3349); // Subtle divider
  static const Color border = Color(0xFF4A4458); // Card borders
  static const Color inputBg = Color(0xFF2A1F3D); // Input background
  static const Color inputBorder = Color(0xFF4A4458); // Input border

  // ── Glass Morphism ──────────────────────────────────────────────────
  static const Color glassDark = Color(0xFF2A1F3D); // 80% opacity
  static const Color glassLight =
      Color(0xFFFFFFFF); // 15% opacity for light variant

  // ── Utility Colors ──────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // ── Gradients ────────────────────────────────────────────────────────
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [darkBackground, darkScaffold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPurple, primaryDeep],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [gradientBlueStart, gradientBlueEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [gradientPurpleStart, gradientPurpleEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient redGradient = LinearGradient(
    colors: [gradientRedStart, gradientRedEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient yellowGradient = LinearGradient(
    colors: [gradientYellowStart, gradientYellowEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [gradientCyanStart, gradientCyanEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
