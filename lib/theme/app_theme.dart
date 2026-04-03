import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Custom non-theme colors
  static const Color surfaceContainerHighest = Color(0xff353534);
  static const Color surfaceContainerHigh = Color(0xff2a2a2a);
  static const Color surfaceContainer = Color(0xff201f1f);
  static const Color surfaceContainerLow = Color(0xff1c1b1b);
  static const Color surfaceContainerLowest = Color(0xff0e0e0e);
  static const Color outlineVariant = Color(0xff444748);

  static final ColorScheme colorScheme = const ColorScheme.dark(
    primary: Color(0xffffb4a1),
    onPrimary: Color(0xff5d1805),
    primaryContainer: Color(0xff2b0400),
    onPrimaryContainer: Color(0xffc16249),
    secondary: Color(0xff9fd1b8),
    onSecondary: Color(0xff023826),
    secondaryContainer: Color(0xff1f4f3c),
    onSecondaryContainer: Color(0xff8ec0a7),
    tertiary: Color(0xffc9c7b5),
    onTertiary: Color(0xff313124),
    tertiaryContainer: Color(0xff131308),
    onTertiaryContainer: Color(0xff807e6e),
    error: Color(0xffffb4ab),
    onError: Color(0xff690005),
    errorContainer: Color(0xff93000a),
    onErrorContainer: Color(0xffffdad6),
    surface: Color(0xff131313),
    onSurface: Color(0xffe5e2e1),
    surfaceContainerHighest: Color(0xff353534),
    onSurfaceVariant: Color(0xffc4c7c7),
    outline: Color(0xff8e9192),
  );

  static ThemeData get theme {
    final baseTextTheme = Typography.material2021().black;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xff131313),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.spaceGrotesk(
            textStyle: baseTextTheme.displayLarge,
            color: colorScheme.onSurface),
        displayMedium: GoogleFonts.spaceGrotesk(
            textStyle: baseTextTheme.displayMedium,
            color: colorScheme.onSurface),
        displaySmall: GoogleFonts.spaceGrotesk(
            textStyle: baseTextTheme.displaySmall,
            color: colorScheme.onSurface),
        headlineLarge: GoogleFonts.spaceGrotesk(
            textStyle: baseTextTheme.headlineLarge,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface),
        headlineMedium: GoogleFonts.spaceGrotesk(
            textStyle: baseTextTheme.headlineMedium,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface),
        headlineSmall: GoogleFonts.spaceGrotesk(
            textStyle: baseTextTheme.headlineSmall,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface),
        titleLarge: GoogleFonts.spaceGrotesk(
            textStyle: baseTextTheme.titleLarge, color: colorScheme.onSurface),
        titleMedium: GoogleFonts.spaceGrotesk(
            textStyle: baseTextTheme.titleMedium, color: colorScheme.onSurface),
        titleSmall: GoogleFonts.spaceGrotesk(
            textStyle: baseTextTheme.titleSmall, color: colorScheme.onSurface),
        bodyLarge: GoogleFonts.inter(
            textStyle: baseTextTheme.bodyLarge, color: colorScheme.onSurface),
        bodyMedium: GoogleFonts.inter(
            textStyle: baseTextTheme.bodyMedium, color: colorScheme.onSurface),
        bodySmall: GoogleFonts.inter(
            textStyle: baseTextTheme.bodySmall, color: colorScheme.onSurface),
        labelLarge: GoogleFonts.ibmPlexMono(
            textStyle: baseTextTheme.labelLarge, color: colorScheme.onSurface),
        labelMedium: GoogleFonts.ibmPlexMono(
            textStyle: baseTextTheme.labelMedium, color: colorScheme.onSurface),
        labelSmall: GoogleFonts.ibmPlexMono(
            textStyle: baseTextTheme.labelSmall, color: colorScheme.onSurface),
      ),
      iconTheme: IconThemeData(
        color: colorScheme.primary,
      ),
    );
  }
}

// Extension to make styles accessible easily
extension ThemeExtensions on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
}
