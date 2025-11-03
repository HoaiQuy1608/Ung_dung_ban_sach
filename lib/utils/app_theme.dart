import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Blue Palette
  static const Color primaryBlue = Color(
    0xFF3B82F6,
  ); // #3B82F6 - Main brand color
  static const Color primaryBlueLight = Color(
    0xFF60A5FA,
  ); // Lighter shade for hover/active states
  static const Color primaryBlueDark = Color(
    0xFF2563EB,
  ); // Darker shade for emphasis
  static const Color primaryBlueVeryDark = Color(
    0xFF1E40AF,
  ); // Deep blue for dark mode

  // Secondary Colors - Analogous palette (Cyan/Teal)
  static const Color secondaryCyan = Color(
    0xFF06B6D4,
  ); // Cyan - analogous to blue
  static const Color secondaryCyanLight = Color(0xFF22D3EE);
  static const Color secondaryCyanDark = Color(0xFF0891B2);

  // Accent Colors - Complementary palette (Orange/Amber)
  static const Color accentOrange = Color(
    0xFFF97316,
  ); // Orange - complementary to blue
  static const Color accentAmber = Color(
    0xFFF59E0B,
  ); // Amber - for warnings/CTAs
  static const Color accentOrangeLight = Color(0xFFFB923C);
  static const Color accentOrangeDark = Color(0xFFEA580C);

  // Semantic Colors
  static const Color successGreen = Color(0xFF10B981); // Success actions
  static const Color successGreenLight = Color(0xFF34D399);
  static const Color successGreenDark = Color(0xFF059669);

  static const Color errorRed = Color(0xFFEF4444); // Error states
  static const Color errorRedLight = Color(0xFFF87171);
  static const Color errorRedDark = Color(0xFFDC2626);

  static const Color warningAmber = Color(0xFFF59E0B); // Warnings
  static const Color warningAmberLight = Color(0xFFFBBF24);
  static const Color warningAmberDark = Color(0xFFD97706);

  // Neutral Colors - Light Mode
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF9FAFB);
  static const Color surfaceVariantLight = Color(0xFFF3F4F6);
  static const Color onBackgroundLight = Color(0xFF111827);
  static const Color onSurfaceLight = Color(0xFF1F2937);
  static const Color onSurfaceVariantLight = Color(0xFF4B5563);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color dividerLight = Color(0xFFD1D5DB);

  // Neutral Colors - Dark Mode
  static const Color backgroundDark = Color(0xFF111827);
  static const Color surfaceDark = Color(0xFF1F2937);
  static const Color surfaceVariantDark = Color(0xFF374151);
  static const Color onBackgroundDark = Color(0xFFF9FAFB);
  static const Color onSurfaceDark = Color(0xFFF3F4F6);
  static const Color onSurfaceVariantDark = Color(0xFFD1D5DB);
  static const Color borderDark = Color(0xFF374151);
  static const Color dividerDark = Color(0xFF4B5563);

  // Star/Rating Colors
  static const Color starYellow = Color(0xFFFCD34D);
  static const Color starAmber = Color(0xFFF59E0B);

  // Private constructor to prevent instantiation
  AppColors._();
}

class AppTheme {
  AppTheme._();

  /// Builds light theme with blue-based palette
  static ThemeData get lightTheme {
    final ColorScheme colorScheme = ColorScheme.light(
      // Primary colors
      primary: AppColors.primaryBlue,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryBlueLight,
      onPrimaryContainer: AppColors.primaryBlueVeryDark,

      // Secondary colors
      secondary: AppColors.secondaryCyan,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondaryCyanLight,
      onSecondaryContainer: AppColors.secondaryCyanDark,

      // Tertiary/Accent colors
      tertiary: AppColors.accentOrange,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.accentOrangeLight,
      onTertiaryContainer: AppColors.accentOrangeDark,

      // Error colors
      error: AppColors.errorRed,
      onError: Colors.white,
      errorContainer: AppColors.errorRedLight,
      onErrorContainer: AppColors.errorRedDark,

      // Surface colors
      surface: AppColors.surfaceLight,
      onSurface: AppColors.onSurfaceLight,
      surfaceVariant: AppColors.surfaceVariantLight,
      onSurfaceVariant: AppColors.onSurfaceVariantLight,
      surfaceTint: AppColors.primaryBlue,

      // Background colors
      background: AppColors.backgroundLight,
      onBackground: AppColors.onBackgroundLight,

      // Outline colors
      outline: AppColors.borderLight,
      outlineVariant: AppColors.dividerLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,

      // Scaffold theme
      scaffoldBackgroundColor: colorScheme.background,
      cardColor: AppColors.surfaceLight,

      // AppBar theme
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: colorScheme.surface,
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Icon theme
      iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant, size: 24),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceVariant,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  /// Builds dark theme with blue-based palette
  static ThemeData get darkTheme {
    final ColorScheme colorScheme = ColorScheme.dark(
      // Primary colors (lighter in dark mode for better visibility)
      primary: AppColors.primaryBlueLight,
      onPrimary: AppColors.primaryBlueVeryDark,
      primaryContainer: AppColors.primaryBlueDark,
      onPrimaryContainer: Colors.white,

      // Secondary colors
      secondary: AppColors.secondaryCyanLight,
      onSecondary: AppColors.secondaryCyanDark,
      secondaryContainer: AppColors.secondaryCyan,
      onSecondaryContainer: Colors.white,

      // Tertiary/Accent colors
      tertiary: AppColors.accentOrangeLight,
      onTertiary: AppColors.accentOrangeDark,
      tertiaryContainer: AppColors.accentOrange,
      onTertiaryContainer: Colors.white,

      // Error colors
      error: AppColors.errorRedLight,
      onError: Colors.white,
      errorContainer: AppColors.errorRed,
      onErrorContainer: AppColors.errorRedDark,

      // Surface colors
      surface: AppColors.surfaceDark,
      onSurface: AppColors.onSurfaceDark,
      surfaceVariant: AppColors.surfaceVariantDark,
      onSurfaceVariant: AppColors.onSurfaceVariantDark,
      surfaceTint: AppColors.primaryBlueLight,

      // Background colors
      background: AppColors.backgroundDark,
      onBackground: AppColors.onBackgroundDark,

      // Outline colors
      outline: AppColors.borderDark,
      outlineVariant: AppColors.dividerDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,

      // Scaffold theme
      scaffoldBackgroundColor: colorScheme.background,
      cardColor: AppColors.surfaceDark,

      // AppBar theme
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: colorScheme.surface,
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Icon theme
      iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant, size: 24),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceVariant,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}

/// Extension methods for easy access to semantic colors from theme
extension ThemeColorExtension on BuildContext {
  /// Get success color
  Color get successColor => AppColors.successGreen;

  /// Get error color from theme
  Color get errorColor => Theme.of(this).colorScheme.error;

  /// Get warning color
  Color get warningColor => AppColors.warningAmber;

  /// Get star/rating color
  Color get starColor => AppColors.starAmber;
}
