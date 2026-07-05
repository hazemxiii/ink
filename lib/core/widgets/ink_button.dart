import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InkButton extends ConsumerStatefulWidget {
  const InkButton({
    super.key,
    required this.onTap,
    this.text,
    this.icon,
    this.isCentered = true,
    required this.backC,
    required this.textC,
    this.hoverBackC,
    this.hoverTextC,
    this.borderC,
    this.hoverBorderC,
    this.isLoading = false,
  });
  final VoidCallback onTap;
  final String? text;
  final IconData? icon;
  final bool isCentered;
  final Color backC;
  final Color textC;
  final Color? borderC;
  final Color? hoverBackC;
  final Color? hoverTextC;
  final Color? hoverBorderC;
  final bool isLoading;

  @override
  ConsumerState<InkButton> createState() => _InkButtonState();
}

class _InkButtonState extends ConsumerState<InkButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final textC = _hover ? widget.hoverTextC ?? widget.textC : widget.textC;
    final backC = _hover
        ? widget.hoverBackC ?? widget.backC.withAlpha(125)
        : widget.backC;
    return InkWell(
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,

      onTap: widget.onTap,
      onHover: (value) {
        setState(() {
          _hover = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backC,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _hover
                ? widget.hoverBorderC ?? widget.borderC ?? Colors.transparent
                : widget.borderC ?? Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: widget.isCentered
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          spacing: 5,
          children: widget.isLoading
              ? [
                  SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(color: textC),
                  ),
                ]
              : [
                  if (widget.icon != null) Icon(widget.icon, color: textC),
                  if (widget.text != null)
                    Text(widget.text!, style: TextStyle(color: textC)),
                ],
        ),
      ),
    );
  }
}
