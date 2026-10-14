import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'quire_tokens.dart';

/// Helper class providing complete ThemeData for Quire in both Light (Warm Paper)
/// and Dark (Warm Charcoal) palettes, strictly derived from QuireTokens.
class QuireTheme {
  const QuireTheme._();

  /// Light Theme: Warm Paper (#FBF9F5) background, terracotta accent (#E76136),
  /// high-contrast on-accent (#241E19), hairline borders (#E8E3DB).
  static ThemeData light() {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: QuireTokens.accentLight,
      onPrimary: QuireTokens.onAccentLight,
      secondary: QuireTokens.accentInkLight,
      onSecondary: QuireTokens.paperLight,
      surface: QuireTokens.surfaceLight,
      onSurface: QuireTokens.inkLight,
      error: const Color(0xFFC13832),
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: QuireTokens.paperLight,
      fontFamily: QuireTokens.fontSerif,
      dividerColor: QuireTokens.ruleLight,
      cardTheme: CardThemeData(
        color: QuireTokens.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(QuireTokens.rCard),
          side: const BorderSide(color: QuireTokens.ruleLight),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: QuireTokens.paperLight,
        foregroundColor: QuireTokens.inkLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: QuireTokens.paperLight,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
    );
  }

  /// Dark Theme: Warm Charcoal (#1A1612) background (never pure black),
  /// vibrant terracotta (#F0834E), high-contrast on-accent (#1A1612),
  /// and dark hairlines (#37322C).
  static ThemeData dark() {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: QuireTokens.accentDark,
      onPrimary: QuireTokens.onAccentDark,
      secondary: QuireTokens.accentInkDark,
      onSecondary: QuireTokens.paperDark,
      surface: QuireTokens.surfaceDark,
      onSurface: QuireTokens.inkDark,
      error: const Color(0xFFF07F77),
      onError: QuireTokens.paperDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: QuireTokens.paperDark,
      fontFamily: QuireTokens.fontSerif,
      dividerColor: QuireTokens.ruleDark,
      cardTheme: CardThemeData(
        color: QuireTokens.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(QuireTokens.rCard),
          side: const BorderSide(color: QuireTokens.ruleDark),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: QuireTokens.paperDark,
        foregroundColor: QuireTokens.inkDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: QuireTokens.paperDark,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
    );
  }
}

/// Controller managing application theme mode (System, Light, Dark).
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController([ThemeMode initialMode = ThemeMode.system]) : super(initialMode);

  /// Toggle between Light and Dark mode manually.
  void toggleTheme(BuildContext context) {
    final isCurrentDark = value == ThemeMode.dark ||
        (value == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    value = isCurrentDark ? ThemeMode.light : ThemeMode.dark;
  }

  /// Explicitly set the theme mode.
  void setThemeMode(ThemeMode mode) {
    if (value != mode) {
      value = mode;
    }
  }
}
