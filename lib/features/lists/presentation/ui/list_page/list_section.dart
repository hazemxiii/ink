import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/viewmodels/theme_viewmodel.dart';
import 'package:ink/core/widgets/ink_button.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';
import 'package:ink/features/lists/presentation/ui/list_page/list_header_widget.dart';
import 'package:ink/features/lists/presentation/ui/list_page/note_widget.dart';
import 'package:ink/features/notes/data/models/note.dart';
import 'package:ink/features/notes/presentation/ui/note_page/note_page.dart';

// TODO multi select

class ListSection extends ConsumerStatefulWidget {
  const ListSection({super.key, required this.list});
  final InkList list;

  @override
  ConsumerState<ListSection> createState() => _ListSectionState();
}

class _ListSectionState extends ConsumerState<ListSection> {
  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeViewmodelProvider);
    return Container(
      padding: const EdgeInsets.all(16),
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
                        return NotePage(
                          note: Note.empty(),
                          list: widget.list,
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
              itemCount: widget.list.notes.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final note = widget.list.notes[index];
                return NoteWidget(note: note, list: widget.list);
              },
            ),
          ),
        ],
      ),
    );
  }
}
