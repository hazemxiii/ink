import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/models/theme/ink_theme.dart';
import 'package:ink/core/services/ink_toast_service.dart';
import 'package:ink/core/viewmodels/theme_viewmodel.dart';
import 'package:ink/core/widgets/delete_list_dialog/delete_list_item_widget.dart';
import 'package:ink/core/widgets/ink_button.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';
import 'package:ink/features/lists/domain/repositories/lists_repository.dart';
import 'package:ink/features/lists/presentation/viewmodels/list_viewmodel.dart';
import 'package:ink/features/lists/presentation/viewmodels/lists_viewmodel.dart';
import 'package:ink/features/lists/presentation/viewmodels/selected_list_viewmodel.dart';

class DeleteListDialog extends ConsumerStatefulWidget {
  const DeleteListDialog({super.key, required this.listId});
  final String listId;

  @override
  ConsumerState<DeleteListDialog> createState() => _DeleteListDialogState();
}

class _DeleteListDialogState extends ConsumerState<DeleteListDialog> {
  late final ListViewmodel _listController;
  late AsyncValue<InkList> _listState;
  late final AsyncValue<WatchListsStreamData> _listsState;
  late final InkTheme _theme;
  bool _isDeleteSelected = false;
  // String? _moveToListId;

  @override
  void initState() {
    _listController = ref.read(listViewmodelProvider(widget.listId).notifier);
    _listsState = ref.watch(listsViewmodelProvider);
    // _isEmpty = _listState.value?.notes.isEmpty??true;

    _theme = ref.watch(themeViewmodelProvider);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _listState = ref.watch(listViewmodelProvider(widget.listId));
    return _listState.when(
      data: (list) {
        final isEmpty = list.notes.isEmpty;
        final moveToLists = (_listsState.value?.lists ?? [])
            .where((l) => l.id != widget.listId)
            .toList();
        if (moveToLists.isEmpty) {
          _isDeleteSelected = true;
        }
        String? moveToListId = moveToLists.firstOrNull?.id;
        return AlertDialog(
          backgroundColor: _theme.backC,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Delete List "${_listState.value!.name}"',
            style: TextStyle(color: _theme.textC),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              isEmpty
                  ? Text(
                      'This list is empty. Deleting it will remove it permanently.',
                      style: TextStyle(color: _theme.secTextC),
                    )
                  : Text(
                      'This list has ${list.notes.length} notes. What would you like to do?',
                      style: TextStyle(color: _theme.secTextC),
                    ),
              if (!isEmpty) ...[
                DeleteListItemWidget(
                  isDelete: true,
                  onTap: () {
                    setState(() {
                      _isDeleteSelected = true;
                    });
                  },
                  isActive: _isDeleteSelected,
                ),
                DeleteListItemWidget(
                  isDelete: false,
                  onTap: () {
                    setState(() {
                      _isDeleteSelected = false;
                    });
                  },
                  isActive: !_isDeleteSelected,
                  listId: moveToListId,
                  moveToLists: moveToLists,
                  onMoveToListTap: (listId) {
                    setState(() {
                      moveToListId = listId;
                    });
                  },
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: _theme.secTextC)),
            ),
            InkButton(
              isMinWidth: true,
              backC: _isDeleteSelected ? _theme.errorC : _theme.mainC,
              textC: _theme.textC,
              text: _isDeleteSelected ? "Delete" : "Move & Delete",
              onTap: () async {
                try {
                  await _listController.deleteList(
                    moveToListId: (_isDeleteSelected || moveToListId == null)
                        ? null
                        : moveToListId,
                  );
                  final selectedListState = ref.read(selectedListProvider);
                  if (selectedListState.value == _listController.id) {
                    ref
                        .read(selectedListProvider.notifier)
                        .selectList(
                          moveToListId ?? moveToLists.firstOrNull?.id,
                        );
                  }
                  ref.invalidate(listsViewmodelProvider);
                  if (moveToListId != null) {
                    ref.invalidate(listViewmodelProvider(moveToListId!));
                  }
                  if (!context.mounted) return;
                  Navigator.pop(context);
                } catch (e) {
                  if (!context.mounted) return;
                  ref
                      .read(inkToastServiceProvider)
                      .showErrorToast(
                        context,
                        _theme,
                        "Error deleting list",
                        e.toString(),
                      );
                }
              },
            ),
          ],
        );
      },
      error: (Object error, StackTrace stackTrace) {
        return Center(child: Text('Error: $error'));
      },
      loading: () {
        return Center(child: CircularProgressIndicator(color: _theme.mainC));
      },
    );
  }
}
