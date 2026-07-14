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

class NotePage extends ConsumerStatefulWidget {
  const NotePage({
    super.key,
    required this._note,
    required this._createNew,
    required this.list,
  });
  final Note _note;
  final InkList list;
  final bool _createNew;

  @override
  ConsumerState<NotePage> createState() => _NoteDialogState();
}

class _NoteDialogState extends ConsumerState<NotePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  late Note _note;
  late InkToastService _toastService;
  LoadingState _loadingState = LoadingState.done;
  bool _pendingSave = false;
  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    _initEmptyNote();
    _titleController.text = widget._note.title;
    _contentController.text = widget._note.content;
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

  void _initEmptyNote() {
    _note = widget._note;
    if (widget._createNew) {
      if (_note.id.isNotEmpty) {
        _note = Note.empty();
      }
      _loadingState = LoadingState.loading;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _createNewNote();
        if (_pendingSave) {
          _pendingSave = false;
          _updateNote();
        } else {
          setState(() {
            _loadingState = LoadingState.done;
          });
        }
      });
    }
  }

  Future<void> _createNewNote() async {
    final theme = ref.watch(themeViewmodelProvider);
    try {
      final id = await ref
          .read(listViewmodelProvider(widget.list.id).notifier)
          .createNote();
      _note = _note.copyWith(id: id);
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
      if (_note.id.isEmpty) {
        _pendingSave = true;
      } else {
        try {
          await ref
              .read(listViewmodelProvider(widget.list.id).notifier)
              .updateNote(_note);
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
