import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/viewmodels/theme_viewmodel.dart';
import 'package:ink/features/lists/presentation/ui/list_page/list_section.dart';
import 'package:ink/features/lists/presentation/viewmodels/list_viewmodel.dart';
import 'package:ink/features/lists/presentation/viewmodels/selected_list_viewmodel.dart';

class ListPage extends ConsumerWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeViewmodelProvider);
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
            return ListSection(list: list);
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
