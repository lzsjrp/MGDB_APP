import 'package:flutter/material.dart';

class GridViewThemeData extends ThemeExtension<GridViewThemeData> {
  final Color cardColor;
  final Color cardBackgroundColor;
  final TextStyle titleStyle;
  final TextStyle authorStyle;
  final Color placeholderIconColor;

  const GridViewThemeData({
    required this.cardColor,
    required this.cardBackgroundColor,
    required this.titleStyle,
    required this.authorStyle,
    required this.placeholderIconColor,
  });

  @override
  GridViewThemeData copyWith({
    Color? cardColor,
    Color? cardBackgroundColor,
    TextStyle? titleStyle,
    TextStyle? authorStyle,
    Color? placeholderIconColor,
  }) {
    return GridViewThemeData(
      cardColor: cardColor ?? this.cardColor,
      cardBackgroundColor: cardBackgroundColor ?? this.cardBackgroundColor,
      titleStyle: titleStyle ?? this.titleStyle,
      authorStyle: authorStyle ?? this.authorStyle,
      placeholderIconColor: placeholderIconColor ?? this.placeholderIconColor,
    );
  }

  @override
  GridViewThemeData lerp(
    ThemeExtension<GridViewThemeData>? other,
    double t,
  ) {
    if (other is! GridViewThemeData) return this;
    return GridViewThemeData(
      cardColor: Color.lerp(cardColor, other.cardColor, t)!,
      cardBackgroundColor: Color.lerp(
        cardBackgroundColor,
        other.cardBackgroundColor,
        t,
      )!,
      titleStyle: TextStyle.lerp(titleStyle, other.titleStyle, t)!,
      authorStyle: TextStyle.lerp(authorStyle, other.authorStyle, t)!,
      placeholderIconColor: Color.lerp(
        placeholderIconColor,
        other.placeholderIconColor,
        t,
      )!,
    );
  }
}
