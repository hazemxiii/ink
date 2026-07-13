import 'package:flutter/material.dart';

class SelectOptionItem {
  const SelectOptionItem({
    required this.text,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String text;
  final IconData icon;
  final Color color;
  final Future<void> Function() onTap;
}
