import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/enums/loading_state.dart';
import 'package:ink/core/services/ink_toast_service.dart';
import 'package:ink/core/viewmodels/theme_viewmodel.dart';
import 'package:ink/core/widgets/text_input.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';
import 'package:ink/features/lists/presentation/viewmodels/list_viewmodel.dart';
import 'package:ink/features/notes/data/models/note.dart';
import 'package:ink/features/notes/presentation/ui/note_page/note_footer.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class NotePage extends ConsumerStatefulWidget {
  const NotePage({super.key, required this._note, required this.list});
  final Note? _note;
  final InkList list;
  @override
  ConsumerState<NotePage> createState() => _NoteDialogState();
}

class _NoteDialogState extends ConsumerState<NotePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  late Note _note;
  late InkToastService _toastService;
  LoadingState _loadingState = LoadingState.done;
  bool _noteCreated = false;
  bool _pendingUpdates = false;
  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    _note = widget._note ?? Note.empty().copyWith(id: const Uuid().v4());
    if (widget._note != null) _noteCreated = true;
    if (!_noteCreated) {
      _createNewNote();
    }
    _titleController.text = _note.title;
    _contentController.text = _note.content;
    _toastService = ref.read(inkToastServiceProvider);
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
                DateFormat("MMM d, yyyy").format(_note.createdAt),
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
          Expanded(
            child: TextInput(
              maxLines: null,
              onChanged: (_) {
                setState(() {
                  _note = _note.copyWith(content: _contentController.text);
                });
                _updateNote();
              },
              controller: _contentController,
              hint: "Type something...",
              noBorder: true,
            ),
          ),

          NoteFooter(
            note: _note,
            loadingState: _loadingState,
            list: widget.list,
          ),
        ],
      ),
    );
  }

  Future<void> _createNewNote() async {
    final theme = ref.watch(themeViewmodelProvider);
    try {
      await ref
          .read(listViewmodelProvider(widget.list.id).notifier)
          .createNote(_note);
      _noteCreated = true;
      if (_pendingUpdates) {
        _pendingUpdates = false;
        _updateNote();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingState = LoadingState.error;
      });
      _toastService.showErrorToast(
        context,
        theme,
        "Error creating note",
        e.toString(),
      );
    }
  }

  Future<void> _updateNote() async {
    setState(() {
      _loadingState = LoadingState.loading;
    });
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 1), () async {
      if (!_noteCreated) {
        _pendingUpdates = true;
      } else {
        try {
          await ref
              .read(listViewmodelProvider(widget.list.id).notifier)
              .updateNote(_note.copyWith(updatedAt: DateTime.now().toUtc()));
          if (mounted) {
            setState(() {
              _loadingState = LoadingState.done;
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _loadingState = LoadingState.error;
            });
          }
        }
      }
    });
  }
}
