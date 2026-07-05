import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/viewmodels/theme_viewmodel.dart';

class TextInput extends ConsumerWidget {
  const TextInput({
    super.key,
    this.isOutlined = true,
    this.hint,
    this.label,
    required this.controller,
    this.textC,
    this.hintC,
    this.borderC,
    this.focusedBorderC,
    this.fillC,
    this.onSubmitted,
    this.textInputAction,
  });

  final bool isOutlined;
  final String? hint;
  final String? label;
  final TextEditingController controller;
  final Color? textC;
  final Color? hintC;
  final Color? borderC;
  final Color? focusedBorderC;
  final Color? fillC;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeViewmodelProvider);
    late final InputBorder border;
    late final InputBorder focusBorder;

    if (isOutlined) {
      border = OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderC ?? theme.borderC),
      );
      focusBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: focusedBorderC ?? borderC ?? theme.borderC,
          width: 2,
        ),
      );
    } else {
      border = UnderlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderC ?? theme.borderC),
      );
      focusBorder = UnderlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: focusedBorderC ?? borderC ?? theme.borderC,
          width: 2,
        ),
      );
    }
    return TextField(
      onSubmitted: onSubmitted,
      textInputAction: textInputAction,
      cursorColor: textC ?? theme.textC,
      style: TextStyle(color: textC ?? theme.textC),
      controller: controller,
      decoration: InputDecoration(
        border: border,
        enabledBorder: border,
        focusedBorder: focusBorder,
        fillColor: fillC,
        filled: fillC != null,
        hintText: hint,
        hintStyle: TextStyle(color: hintC ?? theme.secTextC),
        labelText: label,
        labelStyle: TextStyle(color: hintC ?? theme.secTextC),
      ),
    );
  }
}
