import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/viewmodels/theme_viewmodel.dart';
import 'package:ink/features/lists/presentation/viewmodels/lists_viewmodel.dart';

class MoveToListDialog extends ConsumerWidget {
  const MoveToListDialog({super.key, required this.listId});
  final String listId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeViewmodelProvider);
    final listsState = ref.watch(listsViewmodelProvider);
    final lists = (listsState.value?.lists ?? [])
        .where((list) => list.id != listId)
        .toList();
    return AlertDialog(
      backgroundColor: theme.boxesBackC,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text('Move to List', style: TextStyle(color: theme.textC)),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: lists
            .map(
              (list) => InkWell(
                borderRadius: BorderRadius.circular(8),
                hoverColor: theme.backC,
                onTap: () => Navigator.pop(context, list.id),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 4, backgroundColor: list.color),
                      const SizedBox(width: 4),
                      Text(list.name, style: TextStyle(color: theme.textC)),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
