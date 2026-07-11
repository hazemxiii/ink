import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/enums/loading_state.dart';
import 'package:ink/core/viewmodels/theme_viewmodel.dart';
import 'package:ink/core/widgets/confirm_dialog.dart';
import 'package:ink/core/widgets/ink_button.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';
import 'package:ink/features/lists/presentation/viewmodels/list_viewmodel.dart';
import 'package:ink/features/notes/data/models/note.dart';

class NoteFooter extends ConsumerWidget {
  const NoteFooter({super.key, required this.loadingState, required this.note, required this.list});
  final LoadingState loadingState;
  final Note note;
  final InkList list;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeViewmodelProvider);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.borderC)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkButton(
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => ConfirmDialog(
                  title: "Delete Note",
                  content:
                      "Are you sure you want to delete note \"${note.title}\"?",
                  isDanger: true,
                  confirmText: "Delete",
                ),
              );
              if (confirm == true) {
                ref.read(listViewmodelProvider(list.id).notifier).deleteNote(note.id);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
            backC: theme.backC,
            textC: theme.secTextC,
            text: "Delete",
          ),
          Text(
            loadingState == LoadingState.loading
                ? "SAVING"
                : loadingState == LoadingState.done
                ? "SAVED"
                : "SAVING FAILED",
            style: TextStyle(color: theme.secTextC),
          ),
        ],
      ),
    );
  }
}
