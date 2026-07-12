import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/viewmodels/theme_viewmodel.dart';
import 'package:ink/core/widgets/delete_list_dialog/delete_list_move_to_item.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';

class DeleteListItemWidget extends ConsumerWidget {
  const DeleteListItemWidget({
    super.key,
    required this.isDelete,
    required this.onTap,
    required this.isActive,
    this.listId,
    this.moveToLists = const [],
    this.onMoveToListTap,
  });
  final bool isDelete;
  final VoidCallback onTap;
  final bool isActive;
  final String? listId;
  final List<InkList> moveToLists;
  final Function(String)? onMoveToListTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inactive = !isDelete && moveToLists.isEmpty;
    final theme = ref.watch(themeViewmodelProvider);
    final color = isDelete ? theme.errorC : theme.mainC;
    return IgnorePointer(
      ignoring: inactive,
      child: Opacity(
        opacity: inactive ? 0.5 : 1.0,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: inactive
                  ? Colors.transparent
                  : isActive
                  ? color.withAlpha(10)
                  : theme.boxesBackC,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isActive ? color : theme.borderC),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Row(
                  spacing: 5,
                  children: [
                    Icon(
                      isDelete ? Icons.delete_outline : Icons.folder_outlined,
                      color: color,
                    ),
                    Text(
                      isDelete
                          ? 'Delete content'
                          : 'Move content to another list',
                      style: TextStyle(color: theme.textC),
                    ),
                  ],
                ),
                Text(
                  isDelete
                      ? 'Everything inside this list is removed permanently.'
                      : moveToLists.isEmpty
                      ? "No other lists available — create one first."
                      : 'Notes are preserved in the list you choose below.',
                  style: TextStyle(color: theme.secTextC),
                ),
                if (!isDelete && isActive) ...[
                  const SizedBox(height: 8),
                  if (moveToLists.isNotEmpty)
                    ...moveToLists.map(
                      (list) => DeleteListMoveToItem(
                        list: list,
                        isActive: list.id == listId,
                        onTap: () => onMoveToListTap?.call(list.id),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
