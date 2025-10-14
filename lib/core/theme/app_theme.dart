import 'package:flutter/material.dart';

import 'app_colors.dart';
import './custom/pagination_theme.dart';
import './custom/gridview_theme.dart';
import 'custom/bottom_navbar_theme.dart';

class AppTheme {
  static ThemeData buildTheme(AppColors colors) {
    return ThemeData(
      colorScheme: ColorScheme(
        brightness: colors.brightness,
        primary: colors.primary,
        secondary: colors.secondary,
        surface: colors.surface,
        error: colors.accent,
        onPrimary: colors.onPrimary,
        onSecondary: colors.onSecondary,
        onSurface: colors.onSurface,
        onError: colors.onError,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.progress,
        linearTrackColor: colors.primary,
        circularTrackColor: colors.primary,
        refreshBackgroundColor: colors.primary,
      ),
      scaffoldBackgroundColor: colors.surface,
      appBarTheme: AppBarTheme(backgroundColor: colors.secondary),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.secondary,
        selectedItemColor: colors.selectedItem,
        unselectedItemColor: colors.unselectedItem,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: colors.onPrimary, fontSize: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.accent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.accent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.accent, width: 2),
        ),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        buttonColor: colors.surface,
        textTheme: ButtonTextTheme.primary,
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return colors.textButtonDisabled;
            }
            return colors.textButton;
          }),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.secondary,
          foregroundColor: colors.onPrimary,
          elevation: 4,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.primary,
        barrierColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(
          color: colors.onPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(color: colors.onPrimary, fontSize: 16),
      ),
      extensions: <ThemeExtension<dynamic>>[
        BottomNavBarThemeData(
          backgroundColor: colors.secondary,
          iconColor: colors.unselectedItem,
          activeIconColor: colors.selectedItem,
          tabBackgroundColor: Colors.transparent,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
          tabBorderRadius: 100.0,
          gap: 7,
          iconSize: 24,
        ),
        GridViewThemeData(
          cardColor: colors.secondary,
          cardBackgroundColor: colors.secondary,
          titleStyle: TextStyle(
            color: colors.onPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          authorStyle: TextStyle(color: colors.onSecondary, fontSize: 15),
          placeholderIconColor: colors.onPrimary,
        ),
        PaginationThemeData(
          backgroundColor: colors.secondary,
          textStyle: TextStyle(color: colors.onSurface, fontSize: 14),
          borderRadius: BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              color: colors.primary,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ],
    );
  }

  static ThemeData get darkTheme => buildTheme(AppColorsDark());

  static ThemeData get lightTheme => buildTheme(AppColorsLight());
}
