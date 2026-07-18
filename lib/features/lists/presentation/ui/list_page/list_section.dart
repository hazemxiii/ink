import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/models/select_option_item.dart';
import 'package:ink/core/services/ink_toast_service.dart';
import 'package:ink/core/viewmodels/theme_viewmodel.dart';
import 'package:ink/core/widgets/confirm_dialog.dart';
import 'package:ink/core/widgets/ink_button.dart';
import 'package:ink/core/widgets/select_options_widget.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';
import 'package:ink/features/lists/presentation/ui/list_page/list_header_widget.dart';
import 'package:ink/features/lists/presentation/ui/list_page/move_to_list_dialog.dart';
import 'package:ink/features/lists/presentation/ui/list_page/note_widget.dart';
import 'package:ink/features/lists/presentation/viewmodels/list_viewmodel.dart';
import 'package:ink/features/notes/presentation/ui/note_page/note_page.dart';

class ListSection extends ConsumerStatefulWidget {
  const ListSection({super.key, required this.list});
  final InkList list;

  @override
  ConsumerState<ListSection> createState() => _ListSectionState();
}

class _ListSectionState extends ConsumerState<ListSection> {
  bool _isSelecting = false;
  final Set<String> _selectedNotesIds = {};
  late final ListViewmodel _listController;
  @override
  void initState() {
    _listController = ref.read(listViewmodelProvider(widget.list.id).notifier);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeViewmodelProvider);
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          child: Column(
            children: [
              ListHeaderWidget(list: widget.list),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Notes",
                    style: TextStyle(
                      color: theme.textC,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  InkButton(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return NotePage(note: null, list: widget.list);
                          },
                        ),
                      );
                    },
                    backC: theme.mainC,
                    textC: theme.textC,
                    text: "New Note",
                    icon: Icons.add,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  itemCount: widget.list.notes.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    final note = widget.list.notes[index];
                    return NoteWidget(
                      note: note,
                      list: widget.list,
                      onSelectionChanged: (noteId) {
                        setState(() {
                          _isSelecting = true;
                          if (_selectedNotesIds.contains(noteId)) {
                            _selectedNotesIds.remove(noteId);
                          } else {
                            _selectedNotesIds.add(noteId);
                          }
                        });
                      },
                      isSelected: _selectedNotesIds.contains(note.id),
                      isSelecting: _isSelecting,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        if (_isSelecting)
          Positioned(
            bottom: 10,
            child: SelectOptionsWidget(
              selectedCount: _selectedNotesIds.length,
              options: [
                SelectOptionItem(
                  icon: Icons.folder_outlined,
                  text: 'Move',
                  color: theme.textC,
                  onTap: () async {
                    final listId = await showDialog<String>(
                      context: context,
                      builder: (context) =>
                          MoveToListDialog(listId: widget.list.id),
                    );
                    if (listId != null) {
                      await moveNotes(listId);
                    }
                  },
                ),
                SelectOptionItem(
                  icon: Icons.delete_outlined,
                  text: 'Delete',
                  color: theme.errorC,
                  onTap: () async {
                    final confirmed = await confirmOperation(
                      title: 'Delete Notes',
                      content: 'Are you sure you want to delete these notes?',
                      isDanger: true,
                    );
                    if (confirmed) {
                      await deleteNotes();
                    }
                  },
                ),
              ],
              onCancel: () {
                setState(() {
                  _isSelecting = false;
                  _selectedNotesIds.clear();
                });
              },
            ),
          ),
      ],
    );
  }

  Future<bool> confirmOperation({
    required String title,
    required String content,
    required bool isDanger,
  }) async {
    return await showDialog(
          context: context,
          builder: (context) =>
              ConfirmDialog(title: title, isDanger: isDanger, content: content),
        ) ??
        false;
  }

  Future<void> moveNotes(String targetListId) async {
    final theme = ref.read(themeViewmodelProvider);
    try {
      final result = await _listController.move(
        _selectedNotesIds.toList(),
        targetListId,
      );
      if (!mounted) return;
      final failedNotes = result['failedNotes'] ?? [];
      for (var note in failedNotes) {
        final noteId = note['id'];
        final reason = note['reason'];
        ref
            .read(inkToastServiceProvider)
            .showErrorToast(
              context,
              theme,
              'Error moving note $noteId',
              reason,
            );
      }
      ref.invalidate(listViewmodelProvider(targetListId));
    } catch (e) {
      ref
          .read(inkToastServiceProvider)
          .showErrorToast(context, theme, 'Error moving notes', e.toString());
    } finally {
      setState(() {
        _isSelecting = false;
        _selectedNotesIds.clear();
      });
    }
  }

  Future<void> deleteNotes() async {
    final theme = ref.read(themeViewmodelProvider);

    try {
      final result = await _listController.bulkDeleteNotes(
        _selectedNotesIds.toList(),
      );
      if (!mounted) return;
      final failedNotes = result['failedNotes'] ?? [];
      for (var note in failedNotes) {
        final noteId = note['id'];
        final reason = note['reason'];
        ref
            .read(inkToastServiceProvider)
            .showErrorToast(
              context,
              theme,
              'Error deleting note $noteId',
              reason,
            );
      }
    } catch (e) {
      ref
          .read(inkToastServiceProvider)
          .showErrorToast(context, theme, 'Error deleting notes', e.toString());
    } finally {
      setState(() {
        _isSelecting = false;
        _selectedNotesIds.clear();
      });
    }
  }
}
