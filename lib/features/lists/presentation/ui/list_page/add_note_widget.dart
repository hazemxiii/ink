import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddNoteWidget extends ConsumerStatefulWidget {
  const AddNoteWidget({super.key});

  @override
  ConsumerState<AddNoteWidget> createState() => _AddNoteWidgetState();
}

class _AddNoteWidgetState extends ConsumerState<AddNoteWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
          Text("New Note"),
        ],
      ),
    );
  }
}
