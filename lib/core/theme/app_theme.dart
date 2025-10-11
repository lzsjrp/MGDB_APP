import 'package:flutter/material.dart';
import 'app_colors.dart';

import './custom/pagination_theme.dart';
import './custom/gridview_theme.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.onPrimary,
        brightness: AppColors.brightness,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.progress,
        linearTrackColor: AppColors.primary,
        circularTrackColor: AppColors.primary,
        refreshBackgroundColor: AppColors.primary,
      ),
      scaffoldBackgroundColor: AppColors.primary,
      appBarTheme: const AppBarTheme(backgroundColor: AppColors.secondary),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.secondary,
        selectedItemColor: AppColors.selectedItem,
        unselectedItemColor: AppColors.unselectedItem,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder()),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        buttonColor: AppColors.background,
        textTheme: ButtonTextTheme.primary,
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.textButtonDisabled;
            }
            return AppColors.textButton;
          }),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.onPrimary,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.secondary,
        barrierColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(
          color: AppColors.onPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(color: AppColors.onPrimary, fontSize: 16),
      ),
      extensions: <ThemeExtension<dynamic>>[
        GridViewThemeData(
          cardColor: Color(0xFF1a2231),
          cardBackgroundColor: AppColors.background,
          titleStyle: TextStyle(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          authorStyle: TextStyle(color: Colors.white70, fontSize: 15),
          placeholderIconColor: AppColors.onPrimary,
        ),
        PaginationThemeData(
          backgroundColor: AppColors.secondary,
          textStyle: TextStyle(color: Colors.grey, fontSize: 14),
          borderRadius: BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ],
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.light(
        primary: Colors.blue,
        secondary: Colors.blueAccent,
        surface: Colors.white,
        error: Colors.red,
        onPrimary: Colors.white,
        brightness: Brightness.light,
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return Colors.grey.shade400;
            }
            return Colors.blue;
          }),
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[
        GridViewThemeData(
          cardColor: Colors.white,
          cardBackgroundColor: Colors.grey.shade200,
          titleStyle: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          authorStyle: TextStyle(color: Colors.black54, fontSize: 15),
          placeholderIconColor: Colors.black87,
        ),
        PaginationThemeData(
          backgroundColor: Colors.white,
          textStyle: TextStyle(color: Colors.black87, fontSize: 14),
          borderRadius: BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ],
    );
  }
}
