import 'package:flutter/material.dart';

class PaginationThemeData extends ThemeExtension<PaginationThemeData> {
  final Color backgroundColor;
  final TextStyle textStyle;
  final BorderRadius borderRadius;
  final List<BoxShadow> boxShadow;

  const PaginationThemeData({
    required this.backgroundColor,
    required this.textStyle,
    required this.borderRadius,
    required this.boxShadow,
  });

  @override
  PaginationThemeData copyWith({
    Color? backgroundColor,
    TextStyle? textStyle,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
  }) {
    return PaginationThemeData(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textStyle: textStyle ?? this.textStyle,
      borderRadius: borderRadius ?? this.borderRadius,
      boxShadow: boxShadow ?? this.boxShadow,
    );
  }

  @override
  PaginationThemeData lerp(
      ThemeExtension<PaginationThemeData>? other,
      double t,
      ) {
    if (other is! PaginationThemeData) return this;
    return PaginationThemeData(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t)!,
      borderRadius: BorderRadius.lerp(borderRadius, other.borderRadius, t)!,
      boxShadow: BoxShadow.lerpList(boxShadow, other.boxShadow, t)!,
    );
  }
}
