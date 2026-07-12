import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/viewmodels/theme_viewmodel.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';

class DeleteListMoveToItem extends ConsumerStatefulWidget {
  const DeleteListMoveToItem({
    super.key,
    required this.list,
    required this.isActive,
    required this.onTap,
  });
  final InkList list;
  final bool isActive;
  final VoidCallback onTap;

  @override
  ConsumerState<DeleteListMoveToItem> createState() =>
      _DeleteListMoveToItemState();
}

class _DeleteListMoveToItemState extends ConsumerState<DeleteListMoveToItem> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeViewmodelProvider);
    return InkWell(
      onTap: widget.onTap,
      onHover: (hovered) {
        setState(() {
          _isHovered = hovered;
        });
      },
      child: AnimatedContainer(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: widget.isActive
              ? theme.mainC.withAlpha(50)
              : _isHovered
              ? theme.boxesBackC
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            CircleAvatar(radius: 4, backgroundColor: widget.list.color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.list.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.textC,
                ),
              ),
            ),
            if (widget.isActive) Icon(Icons.check, color: theme.mainC),
          ],
        ),
      ),
    );
  }
}
