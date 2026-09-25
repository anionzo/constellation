import 'package:flutter/material.dart';

/// Design tokens strictly grounded in designs/quire/prototype.html & design-notes.md.
/// Adheres to Anti-Merge invariant C-90: No shared design system, distinct Quire palette.
class QuireTokens {
  // Light Palette (Warm Paper)
  static const Color paperLight = Color(0xFFFBF9F5);
  static const Color surfaceLight = Color(0xFFFFFEFD);
  static const Color s2Light = Color(0xFFF5F0EA);
  static const Color s3Light = Color(0xFFECE6DD);
  static const Color inkLight = Color(0xFF241E19);
  static const Color ink2Light = Color(0xFF605851);
  static const Color ink3Light = Color(0xFF726A64);
  static const Color ruleLight = Color(0xFFE8E3DB);
  static const Color rule2Light = Color(0xFFD7D1C8);
  static const Color accentLight = Color(0xFFE76136); // Warm terracotta
  static const Color accentInkLight = Color(0xFFA52014);
  static const Color accentSoftLight = Color(0xFFFFE2D2);

  // Dark Palette (Warm Charcoal - Never Pure Black)
  static const Color paperDark = Color(0xFF1A1612);
  static const Color surfaceDark = Color(0xFF25211C);
  static const Color s2Dark = Color(0xFF312C26);
  static const Color s3Dark = Color(0xFF3A342C);
  static const Color inkDark = Color(0xFFECE9E4);
  static const Color ink2Dark = Color(0xFFADA8A1);
  static const Color ink3Dark = Color(0xFFA39E96);
  static const Color ruleDark = Color(0xFF37322C);
  static const Color rule2Dark = Color(0xFF4D4740);
  static const Color accentDark = Color(0xFFF0834E);
  static const Color accentInkDark = Color(0xFFFFA26E);
  static const Color accentSoftDark = Color(0xFF592A17);

  // Border Radii
  static const double rPhoto = 10.0;
  static const double rPlate = 14.0;
  static const double rBtn = 13.0;
  static const double rField = 13.0;
  static const double rCard = 18.0;
  static const double rSheet = 22.0;
  static const double rScreen = 44.0; // Device preview corner radius

  // Font Families
  static const String fontSerif = 'Newsreader';
  static const String fontMono = 'JetBrains Mono';

  // Typography Styles
  static TextStyle title({bool isDark = false, double scale = 1.0}) => TextStyle(
        fontFamily: fontSerif,
        fontSize: 27.0 * scale,
        fontWeight: FontWeight.w400,
        height: 1.14,
        letterSpacing: -0.5,
        color: isDark ? inkDark : inkLight,
      );

  static TextStyle h3({bool isDark = false, double scale = 1.0}) => TextStyle(
        fontFamily: fontSerif,
        fontSize: 19.0 * scale,
        fontWeight: FontWeight.w500,
        height: 1.24,
        letterSpacing: -0.3,
        color: isDark ? inkDark : inkLight,
      );

  static TextStyle body({bool isDark = false, double scale = 1.0}) => TextStyle(
        fontFamily: fontSerif,
        fontSize: 14.5 * scale,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: isDark ? ink2Dark : ink2Light,
      );

  static TextStyle eyebrow({bool isDark = false}) => TextStyle(
        fontFamily: fontMono,
        fontSize: 9.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
        color: isDark ? ink2Dark : ink2Light,
      );

  static TextStyle meta({bool isDark = false}) => TextStyle(
        fontFamily: fontMono,
        fontSize: 10.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.7,
        color: isDark ? ink3Dark : ink3Light,
      );

  static TextStyle button({bool isDark = false}) => TextStyle(
        fontFamily: fontSerif,
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        color: isDark ? paperDark : paperLight,
      );
}
