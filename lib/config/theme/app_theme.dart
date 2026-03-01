import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  const AppTheme._();

  static const _black = Color(0xFF111111);
  static const _white = Color(0xFFFFFFFF);
  static const _grey200 = Color(0xFFE5E5E5);
  static const _grey400 = Color(0xFF9E9E9E);
  static const _grey600 = Color(0xFF616161);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _black,
      surface: _white,
      onSurface: _black,
      primary: _black,
      onPrimary: _white,
      secondary: _grey600,
      error: const Color(0xFFB00020),
    );

    final textTheme = ThemeData.light().textTheme.copyWith(
      headlineLarge: const TextStyle(
        fontWeight: FontWeight.w300,
        letterSpacing: 2.0,
        color: _black,
      ),
      headlineMedium: const TextStyle(
        fontWeight: FontWeight.w300,
        letterSpacing: 1.5,
        color: _black,
      ),
      headlineSmall: const TextStyle(
        fontWeight: FontWeight.w400,
        letterSpacing: 1.0,
        color: _black,
      ),
      titleLarge: const TextStyle(
        fontWeight: FontWeight.w400,
        letterSpacing: 1.5,
        fontSize: 18,
        color: _black,
      ),
      titleMedium: const TextStyle(
        fontWeight: FontWeight.w400,
        letterSpacing: 0.8,
        fontSize: 15,
        color: _black,
      ),
      titleSmall: const TextStyle(
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        fontSize: 13,
        color: _black,
      ),
      bodyLarge: const TextStyle(
        fontWeight: FontWeight.w300,
        letterSpacing: 0.3,
        fontSize: 16,
        color: _black,
      ),
      bodyMedium: const TextStyle(
        fontWeight: FontWeight.w300,
        letterSpacing: 0.3,
        fontSize: 14,
        color: _black,
      ),
      bodySmall: const TextStyle(
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        fontSize: 12,
        color: _grey600,
      ),
      labelLarge: const TextStyle(
        fontWeight: FontWeight.w500,
        letterSpacing: 1.5,
        fontSize: 14,
        color: _white,
      ),
      labelMedium: const TextStyle(
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        fontSize: 12,
        color: _grey600,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _white,
      textTheme: textTheme,

      appBarTheme: const AppBarTheme(
        backgroundColor: _white,
        foregroundColor: _black,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: _black,
          fontWeight: FontWeight.w400,
          letterSpacing: 2.0,
          fontSize: 16,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: _black, size: 22),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _black,
          foregroundColor: _white,
          disabledBackgroundColor: _grey200,
          disabledForegroundColor: _grey400,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            letterSpacing: 2.0,
            fontSize: 13,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _black,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: _black, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            letterSpacing: 2.0,
            fontSize: 13,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _black,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            letterSpacing: 1.0,
            fontSize: 13,
          ),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: _black),
      ),

      dividerTheme: const DividerThemeData(
        color: _grey200,
        thickness: 0.5,
        space: 0,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: _grey200),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: _grey200),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: _black, width: 1.5),
        ),
        hintStyle: TextStyle(
          color: _grey400,
          fontWeight: FontWeight.w300,
          letterSpacing: 0.5,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          color: _grey600,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: _white,
        selectedColor: _black,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          letterSpacing: 0.8,
          fontSize: 12,
          color: _black,
        ),
        secondaryLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          letterSpacing: 0.8,
          fontSize: 12,
          color: _white,
        ),
        side: const BorderSide(color: _grey200),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _white,
        elevation: 0,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.8,
              color: _black,
            );
          }
          return const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.8,
            color: _grey400,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: _black, size: 22);
          }
          return const IconThemeData(color: _grey400, size: 22);
        }),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: _black,
        contentTextStyle: const TextStyle(
          color: _white,
          fontWeight: FontWeight.w300,
          letterSpacing: 0.3,
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
      ),

      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: _white,
        shape: RoundedRectangleBorder(),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _black,
      ),

      badgeTheme: const BadgeThemeData(
        backgroundColor: _black,
        textColor: _white,
        smallSize: 6,
        largeSize: 16,
        textStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: _white,
        ),
      ),
    );
  }
}
