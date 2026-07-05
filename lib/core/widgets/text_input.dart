import 'package:flutter/material.dart';

class TextInput extends StatelessWidget {
  const TextInput({
    super.key,
    this.isOutlined = true,
    this.hint,
    this.label,
    required this.controller,
    required this.textC,
    required this.hintC,
    required this.borderC,
    this.focusedBorderC,
    this.fillC,
  });

  final bool isOutlined;
  final String? hint;
  final String? label;
  final TextEditingController controller;
  final Color textC;
  final Color hintC;
  final Color borderC;
  final Color? focusedBorderC;
  final Color? fillC;

  @override
  Widget build(BuildContext context) {
    late final InputBorder border;
    late final InputBorder focusBorder;

    if (isOutlined) {
      border = OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderC),
      );
      focusBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: focusedBorderC ?? borderC, width: 2),
      );
    } else {
      border = UnderlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderC),
      );
      focusBorder = UnderlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: focusedBorderC ?? borderC, width: 2),
      );
    }
    return TextField(
      cursorColor: textC,
      style: TextStyle(color: textC),
      controller: controller,
      decoration: InputDecoration(
        border: border,
        enabledBorder: border,
        focusedBorder: focusBorder,
        fillColor: fillC,
        filled: fillC != null,
        hintText: hint,
        hintStyle: TextStyle(color: hintC),
        labelText: label,
        labelStyle: TextStyle(color: hintC),
      ),
    );
  }
}
