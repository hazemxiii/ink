import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/viewmodels/theme_viewmodel.dart';
import 'package:ink/core/widgets/text_input.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';

class ListHeaderWidget extends ConsumerWidget {
  const ListHeaderWidget({super.key, required this.list});
  final InkList list;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeViewmodelProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          list.name,
          style: TextStyle(
            fontSize: 20,
            color: theme.textC,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          width: 200,
          child: TextInput(
            controller: TextEditingController(),
            textC: theme.textC,
            hintC: theme.secTextC,
            borderC: theme.borderC,
            focusedBorderC: theme.textC,
            hint: "Search Notes",
            fillC: theme.boxesBackC,
          ),
        ),
      ],
    );
  }
}
