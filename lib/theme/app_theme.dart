import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Corner radii and spacing used across the app.
abstract final class AppRadii {
  static const sm = 10.0;
  static const md = 14.0; // inputs, buttons
  static const lg = 18.0; // cards
  static const xl = 22.0; // hero cards (Scan Receipt, Total)
}

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;

  /// Side padding for every screen.
  static const page = EdgeInsets.symmetric(horizontal: 20);
}

/// The SnapSplit look: coral on cream, rounded Nunito, flat soft cards.
///
/// The app is light-only, matching the mockups.
abstract final class AppTheme {
  /// Set to false in tests so Google Fonts doesn't try to download fonts.
  static bool useGoogleFonts = true;

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.coral,
      onPrimary: Colors.white,
      primaryContainer: AppColors.coralSoft,
      onPrimaryContainer: AppColors.coral,
      secondary: AppColors.mint,
      onSecondary: AppColors.ink,
      secondaryContainer: AppColors.mintSoft,
      onSecondaryContainer: AppColors.mintInk,
      tertiary: AppColors.warningInk,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.warningSoft,
      onTertiaryContainer: AppColors.warningInk,
      error: AppColors.error,
      onError: Colors.white,
      surface: AppColors.cream,
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.inkMuted,
      surfaceContainerLowest: AppColors.surface,
      surfaceContainerLow: AppColors.surface,
      surfaceContainer: AppColors.surfaceTint,
      surfaceContainerHigh: AppColors.surfaceTint,
      surfaceContainerHighest: AppColors.surfaceTint,
      outline: AppColors.line,
      outlineVariant: AppColors.line,
      shadow: Color(0x14000000),
      inverseSurface: AppColors.ink,
      onInverseSurface: Colors.white,
    );

    final text = _textTheme();

    final roundedField = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.md),
      borderSide: const BorderSide(color: AppColors.line),
    );

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.md),
    );
    final buttonText = text.labelLarge!.copyWith(fontWeight: FontWeight.w800);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.cream,
      textTheme: text,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.coral,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.coralFaded,
          disabledForegroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: buttonShape,
          textStyle: buttonText,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.line),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.coral,
          textStyle: buttonText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: text.bodyMedium!.copyWith(color: AppColors.inkMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: roundedField,
        enabledBorder: roundedField,
        focusedBorder: roundedField.copyWith(
          borderSide: const BorderSide(color: AppColors.coral, width: 1.5),
        ),
        errorBorder: roundedField.copyWith(
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: roundedField.copyWith(
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        prefixIconColor: AppColors.inkMuted,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        indicatorColor: AppColors.coralSoft,
        indicatorShape: const CircleBorder(),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected)
                ? AppColors.coral
                : AppColors.inkMuted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => text.labelSmall!.copyWith(
            fontWeight: FontWeight.w700,
            color: states.contains(WidgetState.selected)
                ? AppColors.coral
                : AppColors.inkMuted,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.coral
              : AppColors.line,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.coralSoft,
        side: const BorderSide(color: AppColors.line),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        labelStyle: text.labelLarge,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surface,
        contentTextStyle: text.bodyMedium!.copyWith(
          fontWeight: FontWeight.w700,
        ),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.coral,
        linearTrackColor: AppColors.coralSoft,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
      ),
    );
  }

  /// Nunito with heavy, rounded headings like the mockups
  /// ("Welcome back", "Who bought what?").
  static TextTheme _textTheme() {
    const base = TextTheme(
      headlineLarge: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w900,
        height: 1.15,
      ),
      headlineMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w900,
        height: 1.2,
      ),
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        height: 1.2,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        height: 1.25,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        height: 1.3,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        height: 1.3,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.45,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.45,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    );
    final themed = base.apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    );
    return useGoogleFonts ? GoogleFonts.nunitoTextTheme(themed) : themed;
  }
}
