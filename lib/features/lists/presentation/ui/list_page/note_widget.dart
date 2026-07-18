import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/viewmodels/theme_viewmodel.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';
import 'package:ink/features/notes/data/models/note.dart';
import 'package:ink/features/notes/presentation/ui/note_page/note_page.dart';
import 'package:intl/intl.dart';

class NoteWidget extends ConsumerStatefulWidget {
  const NoteWidget({
    super.key,
    required this.note,
    required this.list,
    required this.onSelectionChanged,
    required this.isSelected,
    required this.isSelecting,
  });

  final Note note;
  final InkList list;
  final Function(String noteId) onSelectionChanged;
  final bool isSelected;
  final bool isSelecting;

  @override
  ConsumerState<NoteWidget> createState() => _NoteWidgetState();
}

class _NoteWidgetState extends ConsumerState<NoteWidget>
    with TickerProviderStateMixin {
  late final AnimationController _hoverController;
  late final Animation<double> _hoverAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _hoverAnimation = Tween<double>(begin: 0, end: 1).animate(_hoverController);
    _hoverController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeViewmodelProvider);
    return InkWell(
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onLongPress: widget.isSelecting
          ? null
          : () {
              widget.onSelectionChanged(widget.note.id);
            },
      onTap: () {
        if (widget.isSelecting) {
          widget.onSelectionChanged(widget.note.id);
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return NotePage(note: widget.note, list: widget.list);
            },
          ),
        );
      },
      onHover: (value) {
        value ? _hoverController.forward() : _hoverController.reverse();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.boxesBackC,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isSelected
                ? theme.mainC
                : Color.lerp(
                    theme.borderC,
                    theme.textC,
                    _hoverAnimation.value,
                  )!,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 5,
              children: [
                CircleAvatar(radius: 3, backgroundColor: theme.mainC),
                Text(
                  DateFormat("MMM d, yyyy").format(widget.note.createdAt),
                  style: TextStyle(color: theme.secTextC),
                ),
                if (widget.isSelecting) ...[
                  const Spacer(),
                  Checkbox(
                    activeColor: theme.mainC,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    value: widget.isSelected,
                    onChanged: (value) {
                      widget.onSelectionChanged(widget.note.id);
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Text(
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              widget.note.title,
              style: TextStyle(
                color: Color.lerp(
                  theme.textC,
                  theme.mainC,
                  _hoverAnimation.value,
                )!,
                fontSize: 18,
              ),
            ),
            Text(
              "${widget.note.content.length} words",
              style: TextStyle(color: theme.secTextC),
            ),
          ],
        ),
      ),
    );
  }
}
