import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/models/theme/ink_theme.dart';
import 'package:ink/core/services/ink_toast_service.dart';
import 'package:ink/core/viewmodels/theme_viewmodel.dart';
import 'package:ink/core/widgets/delete_list_dialog/delete_list_item_widget.dart';
import 'package:ink/core/widgets/ink_button.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';
import 'package:ink/features/lists/presentation/viewmodels/list_viewmodel.dart';
import 'package:ink/features/lists/presentation/viewmodels/lists_viewmodel.dart';

class DeleteListDialog extends ConsumerStatefulWidget {
  const DeleteListDialog({super.key, required this.listId});
  final String listId;

  @override
  ConsumerState<DeleteListDialog> createState() => _DeleteListDialogState();
}

class _DeleteListDialogState extends ConsumerState<DeleteListDialog> {
  late final ListViewmodel _listController;
  late final AsyncValue<InkList> _listState;
  late final List<InkList> _moveToLists;
  late final AsyncValue<List<InkList>> _listsState;
  late final InkTheme _theme;
  late final bool _isEmpty;
  bool _isDeleteSelected = false;
  String? _moveToListId;

  @override
  void initState() {
    _listController = ref.read(listViewmodelProvider(widget.listId).notifier);
    _listState = ref.watch(listViewmodelProvider(widget.listId));
    _listsState = ref.watch(listsViewmodelProvider);
    _isEmpty = _listState.value!.notes.isEmpty;
    _moveToLists = _listsState.value!
        .where((list) => list.id != widget.listId)
        .toList();
    _moveToListId = _moveToLists.firstOrNull?.id;
    _theme = ref.watch(themeViewmodelProvider);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _theme.backC,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        'Delete List ${_listState.value!.name}',
        style: TextStyle(color: _theme.textC),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          _isEmpty
              ? Text(
                  'This list is empty. Deleting it will remove it permanently.',
                  style: TextStyle(color: _theme.secTextC),
                )
              : Text(
                  'This list has ${_listState.value!.notes.length} notes. What would you like to do?',
                  style: TextStyle(color: _theme.secTextC),
                ),

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
            listId: _moveToListId,
            moveToLists: _moveToLists,
            onMoveToListTap: (listId) {
              setState(() {
                _moveToListId = listId;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: _theme.secTextC)),
        ),
        InkButton(
          isMinWidth: true,
          backC: _theme.errorC,
          textC: _theme.textC,
          onTap: () async {
            try {
              await _listController.deleteList();
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
          text: "Delete",
        ),
      ],
    );
  }
}
