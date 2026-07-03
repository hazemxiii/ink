import 'package:flutter/material.dart';

extension ColorExt on Color {
  String get toHex {
    return "#${toARGB32().toRadixString(16).toUpperCase().padLeft(8, 'F')}";
  }
}
