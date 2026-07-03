import 'dart:ui';
import 'package:flutter/material.dart';

extension StringExt on String {
  Color get toColor {
    String hexColor = this;
    if (hexColor.startsWith("#")) {
      hexColor = hexColor.substring(1);
    }
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}
