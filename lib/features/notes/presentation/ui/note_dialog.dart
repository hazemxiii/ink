import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/features/notes/data/models/note.dart';

class NoteDialog extends ConsumerStatefulWidget {
  const NoteDialog({super.key, required this._note, required this._createNew});
  final Note _note;
  final bool _createNew;

  @override
  ConsumerState<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends ConsumerState<NoteDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _titleController.text = widget._note.title;
    _contentController.text = widget._note.content;
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _contentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
