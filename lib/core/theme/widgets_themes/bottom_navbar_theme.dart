import 'dart:ui';

import 'package:flutter/material.dart';

class BottomNavBarThemeData extends ThemeExtension<BottomNavBarThemeData> {
  final Color backgroundColor;
  final Color iconColor;
  final Color activeIconColor;
  final Color tabBackgroundColor;
  final TextStyle labelStyle;
  final EdgeInsetsGeometry padding;
  final double gap;
  final double iconSize;
  final double tabBorderRadius;

  const BottomNavBarThemeData({
    required this.backgroundColor,
    required this.iconColor,
    required this.activeIconColor,
    required this.tabBackgroundColor,
    required this.labelStyle,
    required this.padding,
    required this.gap,
    required this.iconSize,
    required this.tabBorderRadius,
  });

  @override
  BottomNavBarThemeData copyWith({
    Color? backgroundColor,
    Color? iconColor,
    Color? activeIconColor,
    Color? tabBackgroundColor,
    TextStyle? labelStyle,
    EdgeInsetsGeometry? padding,
    double? gap,
    double? iconSize,
    double? tabBorderRadius,
  }) {
    return BottomNavBarThemeData(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      iconColor: iconColor ?? this.iconColor,
      activeIconColor: activeIconColor ?? this.activeIconColor,
      tabBackgroundColor: tabBackgroundColor ?? this.tabBackgroundColor,
      labelStyle: labelStyle ?? this.labelStyle,
      padding: padding ?? this.padding,
      gap: gap ?? this.gap,
      iconSize: iconSize ?? this.iconSize,
      tabBorderRadius: tabBorderRadius ?? this.tabBorderRadius,
    );
  }

  @override
  BottomNavBarThemeData lerp(
    ThemeExtension<BottomNavBarThemeData>? other,
    double t,
  ) {
    if (other is! BottomNavBarThemeData) return this;
    return BottomNavBarThemeData(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      iconColor: Color.lerp(iconColor, other.iconColor, t)!,
      activeIconColor: Color.lerp(activeIconColor, other.activeIconColor, t)!,
      tabBackgroundColor: Color.lerp(
        tabBackgroundColor,
        other.tabBackgroundColor,
        t,
      )!,
      labelStyle: TextStyle.lerp(labelStyle, other.labelStyle, t)!,
      padding: EdgeInsetsGeometry.lerp(padding, other.padding, t)!,
      gap: lerpDouble(gap, other.gap, t)!,
      iconSize: lerpDouble(iconSize, other.iconSize, t)!,
      tabBorderRadius: lerpDouble(tabBorderRadius, other.tabBorderRadius, t)!,
    );
  }
}
