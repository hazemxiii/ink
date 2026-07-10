import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/viewmodels/theme_viewmodel.dart';
import 'package:ink/core/widgets/ink_button.dart';
import 'package:ink/features/lists/presentation/ui/list_page/list_header_widget.dart';
import 'package:ink/features/lists/presentation/ui/list_page/note_widget.dart';
import 'package:ink/features/lists/presentation/viewmodels/list_viewmodel.dart';
import 'package:ink/features/lists/presentation/viewmodels/selected_list_viewmodel.dart';
import 'package:ink/features/notes/data/models/note.dart';
import 'package:ink/features/notes/presentation/ui/note_dialog/note_dialog.dart';

class ListPage extends ConsumerWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeViewmodelProvider);
    // TODO implement list page
    final selectedList = ref.watch(selectedListProvider);
    return selectedList.when(
      data: (data) {
        if (data == null) {
          return Center(
            child: Text(
              "Select a list to view",
              style: TextStyle(
                color: theme.textC,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
        final listState = ref.watch(listViewmodelProvider(data));
        return listState.when(
          data: (list) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListHeaderWidget(list: list),
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
                                return NoteDialog(
                                  note: Note.empty(),
                                  list: list,
                                  createNew: true,
                                );
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
                      itemCount: list.notes.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                          ),
                      itemBuilder: (context, index) {
                        final note = list.notes[index];
                        return NoteWidget(note: note, list: list);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
          error: (error, stackTrace) {
            return Text("error: $error");
          },
          loading: () {
            return const Center(child: CircularProgressIndicator());
          },
        );
      },
      error: (error, stackTrace) {
        return Text("error: $error");
      },
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
