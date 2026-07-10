import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/viewmodels/theme_viewmodel.dart';
import 'package:ink/core/widgets/text_input.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';
import 'package:ink/features/lists/presentation/viewmodels/list_viewmodel.dart';
import 'package:ink/features/notes/data/models/note.dart';
import 'package:ink/features/notes/presentation/ui/note_dialog/page_footer.dart';
import 'package:intl/intl.dart';

class NoteDialog extends ConsumerStatefulWidget {
  const NoteDialog({
    super.key,
    required this._note,
    required this._createNew,
    required this.list,
  });
  final Note _note;
  final InkList list;
  final bool _createNew;

  @override
  ConsumerState<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends ConsumerState<NoteDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  late Note _note;
  bool _isLoading = false;
  bool _pendingSave = false;
  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    _initEmptyNote();
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
    final theme = ref.watch(themeViewmodelProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(backgroundColor: widget.list.color, radius: 4),
              const SizedBox(width: 4),
              Text(
                DateFormat("MMM d, yyyy").format(widget._note.createdAt),
                style: TextStyle(color: theme.secTextC),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, color: theme.secTextC),
              ),
            ],
          ),
          TextInput(
            onChanged: (_) {
              setState(() {
                _note = _note.copyWith(title: _titleController.text);
              });
              _updateNote();
            },
            controller: _titleController,
            hint: "Title",
            noBorder: true,
          ),
          const Spacer(),
          PageFooter(note: _note, isLoading: _isLoading),
        ],
      ),
    );
  }

  void _initEmptyNote() {
    _note = widget._note;
    if (widget._createNew) {
      if (_note.id.isNotEmpty) {
        _note = Note.empty();
      }
      _isLoading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _createNewNote();
        if (_pendingSave) {
          _pendingSave = false;
          _updateNote();
        }
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  Future<void> _createNewNote() async {
    try {
      final id = await ref
          .read(listViewmodelProvider(widget.list.id).notifier)
          .createNote();
      _note = _note.copyWith(id: id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _updateNote() async {
    setState(() {
      _isLoading = true;
    });
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (_note.id.isEmpty) {
        _pendingSave = true;
      } else {
        print("Updating note:${_note.toJson()}");
        // TODO update note
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
  }
}
