import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LightModeColors {
  static const lightPrimary = Color(0xFF684F8E);
  static const lightOnPrimary = Color(0xFFFFFFFF);
  static const lightPrimaryContainer = Color(0xFFEAE0FF);
  static const lightOnPrimaryContainer = Color(0xFF23105F);
  static const lightSecondary = Color(0xFF635D70);
  static const lightOnSecondary = Color(0xFFFFFFFF);
  static const lightTertiary = Color(0xFF7E525D);
  static const lightOnTertiary = Color(0xFFFFFFFF);
  static const lightError = Color(0xFFBA1A1A);
  static const lightOnError = Color(0xFFFFFFFF);
  static const lightErrorContainer = Color(0xFFFFDAD6);
  static const lightOnErrorContainer = Color(0xFF410002);
  static const lightInversePrimary = Color(0xFFC6B3F7);
  static const lightShadow = Color(0xFF000000);
  static const lightSurface = Color(0xFFFAFAFA);
  static const lightOnSurface = Color(0xFF1C1C1C);
  static const lightAppBarBackground = Color(0xFFEAE0FF);
}

class DarkModeColors {
  static const darkPrimary = Color(0xFFD4BCCF);
  static const darkOnPrimary = Color(0xFF38265C);
  static const darkPrimaryContainer = Color(0xFF4F3D74);
  static const darkOnPrimaryContainer = Color(0xFFEAE0FF);
  static const darkSecondary = Color(0xFFCDC3DC);
  static const darkOnSecondary = Color(0xFF34313F);
  static const darkTertiary = Color(0xFFF0B6C5);
  static const darkOnTertiary = Color(0xFF4A2530);
  static const darkError = Color(0xFFFFB4AB);
  static const darkOnError = Color(0xFF690005);
  static const darkErrorContainer = Color(0xFF93000A);
  static const darkOnErrorContainer = Color(0xFFFFDAD6);
  static const darkInversePrimary = Color(0xFF684F8E);
  static const darkShadow = Color(0xFF000000);
  static const darkSurface = Color(0xFF121212);
  static const darkOnSurface = Color(0xFFE0E0E0);
  static const darkAppBarBackground = Color(0xFF4F3D74);
}

class Spacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class Radii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;
}

class FontSizes {
  static const double displayLarge = 57.0;
  static const double displayMedium = 45.0;
  static const double displaySmall = 36.0;
  static const double headlineLarge = 32.0;
  static const double headlineMedium = 24.0;
  static const double headlineSmall = 22.0;
  static const double titleLarge = 22.0;
  static const double titleMedium = 18.0;
  static const double titleSmall = 16.0;
  static const double labelLarge = 16.0;
  static const double labelMedium = 14.0;
  static const double labelSmall = 12.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
}

class AppColorsLight {
  static const Color primary = Color(0xFF006FEE);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFD6E4FF);
  static const Color onPrimaryContainer = Color(0xFF001945);
  static const Color secondary = Color(0xFF00C2A8);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF7F8FA);
  static const Color onSurface = Color(0xFF111318);
  static const Color error = Color(0xFFDC362E);
  static const Color onError = Color(0xFFFFFFFF);
}

class AppColorsDark {
  static const Color primary = Color(0xFF82B6FF);
  static const Color onPrimary = Color(0xFF002A6B);
  static const Color primaryContainer = Color(0xFF003A99);
  static const Color onPrimaryContainer = Color(0xFFD6E4FF);
  static const Color secondary = Color(0xFF4DE1CB);
  static const Color onSecondary = Color(0xFF00352D);
  static const Color surface = Color(0xFF0E1116);
  static const Color onSurface = Color(0xFFE6E9EF);
  static const Color error = Color(0xFFFFB4A9);
  static const Color onError = Color(0xFF690005);
}

ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: AppColorsLight.primary,
    onPrimary: AppColorsLight.onPrimary,
    secondary: AppColorsLight.secondary,
    onSecondary: AppColorsLight.onSecondary,
    error: AppColorsLight.error,
    onError: AppColorsLight.onError,
    surface: AppColorsLight.surface,
    onSurface: AppColorsLight.onSurface,
    primaryContainer: AppColorsLight.primaryContainer,
    onPrimaryContainer: AppColorsLight.onPrimaryContainer,
    tertiary: AppColorsLight.secondary,
    onTertiary: AppColorsLight.onSecondary,
  ),
  brightness: Brightness.light,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColorsLight.primaryContainer,
    foregroundColor: AppColorsLight.onPrimaryContainer,
    elevation: 0,
  ),
  cardTheme: CardThemeData(
    color: AppColorsLight.surface,
    elevation: 1,
    margin: const EdgeInsets.all(0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.lg)),
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: AppColorsLight.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.lg)),
  ),
  tabBarTheme: const TabBarThemeData(
    labelColor: AppColorsLight.onSurface,
    unselectedLabelColor: AppColorsLight.onSurface,
    indicatorColor: AppColorsLight.primary,
    dividerColor: AppColorsLight.onSurface,
    labelPadding: EdgeInsets.symmetric(horizontal: 16),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return AppColorsLight.primaryContainer;
        if (states.contains(WidgetState.hovered)) return AppColorsLight.primaryContainer;
        return AppColorsLight.primary;
      }),
      foregroundColor: WidgetStateProperty.all(AppColorsLight.onPrimary),
      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md))),
      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
      elevation: WidgetStateProperty.all(0),
    ),
  ),
  chipTheme: const ChipThemeData(showCheckmark: false),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColorsLight.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(Radii.lg), borderSide: BorderSide(color: AppColorsLight.onSurface)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Radii.lg), borderSide: BorderSide(color: AppColorsLight.onSurface)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Radii.lg), borderSide: const BorderSide(color: AppColorsLight.primary)),
  ),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.inter(
      fontSize: FontSizes.displayLarge,
      fontWeight: FontWeight.normal,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: FontSizes.displayMedium,
      fontWeight: FontWeight.normal,
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: FontSizes.displaySmall,
      fontWeight: FontWeight.w600,
    ),
    headlineLarge: GoogleFonts.inter(
      fontSize: FontSizes.headlineLarge,
      fontWeight: FontWeight.normal,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: FontSizes.headlineMedium,
      fontWeight: FontWeight.w500,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: FontSizes.headlineSmall,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: FontSizes.titleLarge,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: FontSizes.titleMedium,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: FontSizes.titleSmall,
      fontWeight: FontWeight.w500,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: FontSizes.labelLarge,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: FontSizes.labelMedium,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: FontSizes.labelSmall,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: FontSizes.bodyLarge,
      fontWeight: FontWeight.normal,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: FontSizes.bodyMedium,
      fontWeight: FontWeight.normal,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: FontSizes.bodySmall,
      fontWeight: FontWeight.normal,
    ),
  ),
);

ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: AppColorsDark.primary,
    onPrimary: AppColorsDark.onPrimary,
    secondary: AppColorsDark.secondary,
    onSecondary: AppColorsDark.onSecondary,
    error: AppColorsDark.error,
    onError: AppColorsDark.onError,
    surface: AppColorsDark.surface,
    onSurface: AppColorsDark.onSurface,
    primaryContainer: AppColorsDark.primaryContainer,
    onPrimaryContainer: AppColorsDark.onPrimaryContainer,
    tertiary: AppColorsDark.secondary,
    onTertiary: AppColorsDark.onSecondary,
  ),
  brightness: Brightness.dark,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColorsDark.primaryContainer,
    foregroundColor: AppColorsDark.onPrimaryContainer,
    elevation: 0,
  ),
  cardTheme: CardThemeData(
    color: AppColorsDark.surface,
    elevation: 1,
    margin: const EdgeInsets.all(0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.lg)),
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: AppColorsDark.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.lg)),
  ),
  tabBarTheme: const TabBarThemeData(
    labelColor: AppColorsDark.onSurface,
    unselectedLabelColor: AppColorsDark.onSurface,
    indicatorColor: AppColorsDark.primary,
    dividerColor: AppColorsDark.onSurface,
    labelPadding: EdgeInsets.symmetric(horizontal: 16),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return AppColorsDark.primaryContainer;
        if (states.contains(WidgetState.hovered)) return AppColorsDark.primaryContainer;
        return AppColorsDark.primary;
      }),
      foregroundColor: WidgetStateProperty.all(AppColorsDark.onPrimary),
      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md))),
      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
      elevation: WidgetStateProperty.all(0),
    ),
  ),
  chipTheme: const ChipThemeData(showCheckmark: false),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColorsDark.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(Radii.lg), borderSide: BorderSide(color: AppColorsDark.onSurface)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Radii.lg), borderSide: BorderSide(color: AppColorsDark.onSurface)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Radii.lg), borderSide: const BorderSide(color: AppColorsDark.primary)),
  ),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.inter(
      fontSize: FontSizes.displayLarge,
      fontWeight: FontWeight.normal,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: FontSizes.displayMedium,
      fontWeight: FontWeight.normal,
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: FontSizes.displaySmall,
      fontWeight: FontWeight.w600,
    ),
    headlineLarge: GoogleFonts.inter(
      fontSize: FontSizes.headlineLarge,
      fontWeight: FontWeight.normal,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: FontSizes.headlineMedium,
      fontWeight: FontWeight.w500,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: FontSizes.headlineSmall,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: FontSizes.titleLarge,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: FontSizes.titleMedium,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: FontSizes.titleSmall,
      fontWeight: FontWeight.w500,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: FontSizes.labelLarge,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: FontSizes.labelMedium,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: FontSizes.labelSmall,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: FontSizes.bodyLarge,
      fontWeight: FontWeight.normal,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: FontSizes.bodyMedium,
      fontWeight: FontWeight.normal,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: FontSizes.bodySmall,
      fontWeight: FontWeight.normal,
    ),
  ),
);
