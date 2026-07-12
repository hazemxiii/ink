import 'package:flex_color_picker/flex_color_picker.dart';
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
    const Color(0xFFFF007F),
  ];
  Color? _customColor;

  @override
  void initState() {
    if (!_colors.contains(widget.selectedColor)) {
      _customColor = widget.selectedColor;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 5,
        children: [
          ..._colors.map(_colorWidget),
          if (_customColor != null) _colorWidget(_customColor!),
          _addNewColorButton(),
        ],
      ),
    );
  }

  Widget _colorWidget(Color c) {
    final theme = ref.watch(themeViewmodelProvider);
    return InkWell(
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () => widget.onColorChanged(c),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: c,
          border: Border.all(
            width: 2,
            color: widget.selectedColor == c ? theme.mainC : theme.textC,
          ),
        ),
        child: Visibility(
          visible: widget.selectedColor == c,
          child: Container(
            decoration: BoxDecoration(
              color: theme.mainC.withAlpha(150),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: theme.textC, size: 16),
          ),
        ),
      ),
    );
  }

  Widget _addNewColorButton() {
    final theme = ref.watch(themeViewmodelProvider);
    return IconButton(
      color: theme.mainC,
      onPressed: () async {
        final newColor = await _getNewColor();
        setState(() {
          if (_colors.contains(newColor)) {
            widget.onColorChanged(newColor);
          } else {
            _customColor = newColor;
            widget.onColorChanged(_customColor!);
          }
        });
      },
      icon: const Icon(Icons.add),
    );
  }

  Future<Color> _getNewColor() async {
    final theme = ref.read(themeViewmodelProvider);
    return await showColorPickerDialog(
      context,
      _customColor ?? theme.mainC,
      backgroundColor: theme.backC,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.borderC),
      ),
      showColorCode: true,
      colorCodeHasColor: true,
      actionButtons: ColorPickerActionButtons(
        dialogOkButtonStyle: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(theme.mainC),
        ),
        dialogCancelButtonStyle: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(theme.textC),
        ),
      ),
      pickersEnabled: <ColorPickerType, bool>{
        ColorPickerType.wheel: true,
        ColorPickerType.accent: false,
        ColorPickerType.primary: false,
      },
    );
  }
}
