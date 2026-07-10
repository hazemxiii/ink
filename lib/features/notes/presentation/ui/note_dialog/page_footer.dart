import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/viewmodels/theme_viewmodel.dart';
import 'package:ink/core/widgets/ink_button.dart';
import 'package:ink/features/notes/data/models/note.dart';

class PageFooter extends ConsumerWidget {
  const PageFooter({super.key, required this.isLoading, required this.note});
  final bool isLoading;
  final Note note;

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
            onTap: () {},
            backC: theme.backC,
            textC: theme.secTextC,
            text: "Delete",
          ),
          Text(
            isLoading ? "SAVING" : "SAVED",
            style: TextStyle(color: theme.secTextC),
          ),
        ],
      ),
    );
  }
}
