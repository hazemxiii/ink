import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/viewmodels/theme_viewmodel.dart';

class ColorPickerRow extends ConsumerStatefulWidget {
  const ColorPickerRow({
    super.key,
    required this.selectedColor,
    required this.onColorChanged,
  });
  final Color selectedColor;
  final Function(Color) onColorChanged;

  @override
  ConsumerState<ColorPickerRow> createState() => _ColorPickerRowState();
}

class _ColorPickerRowState extends ConsumerState<ColorPickerRow> {
  final _colors = [
    Colors.white,
    Colors.black,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.pink,
  ];
  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeViewmodelProvider);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 5,
        children: [
          ..._colors.map((c) {
            return InkWell(
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: () => widget.onColorChanged(c),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c,
                  border: Border.all(
                    color: widget.selectedColor == c
                        ? theme.mainC
                        : theme.textC,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
