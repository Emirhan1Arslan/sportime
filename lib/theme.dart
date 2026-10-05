import 'package:flutter/material.dart';

/// TBF SPORTIME ekranlarındaki kırmızı marka rengi.
const brandRed = Color(0xFFE53935);
const brandRedDark = Color(0xFFB71C1C);
const liveRed = Color(0xFFD50000);
const winGreen = Color(0xFF2E7D32);
const warnAmber = Color(0xFFF57C00);

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: brandRed,
    primary: brandRed,
    surface: const Color(0xFFFAF8F8),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFFF5F3F3),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF5F3F3),
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1C1B1B),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: brandRed,
      indicatorColor: Colors.white,
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected) ? brandRed : Colors.white70,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: s.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w400,
        ),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
