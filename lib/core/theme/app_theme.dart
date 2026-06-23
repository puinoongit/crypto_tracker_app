import 'package:flutter/material.dart';

/// App-wide Material 3 themes for light and dark mode.
///
/// Palette: deep teal seed on warm dark surfaces — tuned for reading prices
/// and 24h deltas at a glance without relying on generic blue Material defaults.
abstract final class AppTheme {
  static const Color _seed = Color(0xFF00C9A7);
  static const Color brand = _seed;
  static const Color _darkSurface = Color(0xFF0F1419);
  static const Color darkSurface = _darkSurface;
  static const Color _darkSurfaceContainer = Color(0xFF1A222D);

  static const double cardRadius = 18;

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
      surface: brightness == Brightness.dark ? _darkSurface : null,
      surfaceContainerHighest: brightness == Brightness.dark
          ? _darkSurfaceContainer
          : null,
    );

    final baseText = Typography.material2021().black;
    final textTheme =
        (brightness == Brightness.dark
                ? Typography.material2021().white
                : baseText)
            .apply(
              bodyColor: colorScheme.onSurface,
              displayColor: colorScheme.onSurface,
            )
            .copyWith(
              titleLarge: TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: colorScheme.onSurface,
              ),
              titleMedium: TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
                color: colorScheme.onSurface,
              ),
              titleSmall: TextStyle(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              labelSmall: TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
                color: colorScheme.onSurfaceVariant,
              ),
            );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: brightness == Brightness.dark
          ? _darkSurface
          : colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest.withValues(
          alpha: brightness == Brightness.dark ? 0.85 : 0.95,
        ),
        indicatorColor: colorScheme.primary.withValues(alpha: 0.18),
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelSmall?.copyWith(letterSpacing: 0.2),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
        color: colorScheme.surfaceContainerHighest.withValues(
          alpha: brightness == Brightness.dark ? 0.55 : 0.45,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(
          alpha: brightness == Brightness.dark ? 0.65 : 0.5,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        space: 1,
        thickness: 1,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}

/// Semantic colors that aren't part of [ColorScheme] (gains/losses).
extension MarketColors on ColorScheme {
  Color get positive => brightness == Brightness.dark
      ? const Color(0xFF3DDC97)
      : const Color(0xFF0D9B63);

  Color get negative => brightness == Brightness.dark
      ? const Color(0xFFFF7B7B)
      : const Color(0xFFE53935);

  /// Accent gradient for hero cards (market overview).
  List<Color> get heroGradient => brightness == Brightness.dark
      ? [primary.withValues(alpha: 0.35), const Color(0xFF1A222D)]
      : [primary.withValues(alpha: 0.22), surfaceContainerHighest];
}
