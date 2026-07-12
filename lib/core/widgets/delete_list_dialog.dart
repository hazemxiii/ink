import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/features/lists/presentation/viewmodels/list_viewmodel.dart';

class DeleteListDialog extends ConsumerStatefulWidget {
  const DeleteListDialog({super.key, required this.listId});
  final String listId;

  @override
  ConsumerState<DeleteListDialog> createState() => _DeleteListDialogState();
}

class _DeleteListDialogState extends ConsumerState<DeleteListDialog> {
  late final ListViewmodel _listController;

  @override
  void initState() {
    _listController = ref.read(listViewmodelProvider(widget.listId).notifier);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete List'),
      content: const Text('Are you sure you want to delete this list?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            try {
              _listController.deleteList();
            } catch (e) {
              debugPrint('Error deleting list: $e');
            }
            Navigator.pop(context);
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
