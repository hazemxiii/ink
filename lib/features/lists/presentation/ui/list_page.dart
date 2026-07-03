import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/features/lists/presentation/viewmodels/list_viewmodel.dart';
import 'package:ink/features/lists/presentation/viewmodels/selected_list_viewmodel.dart';

class ListPage extends ConsumerWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final theme = ref.watch(themeViewmodelProvider);
    // TODO implement list page
    final selectedList = ref.watch(selectedListProvider);
    return selectedList.when(
      data: (data) {
        if (data == null) {
          return const Text("Please select a list");
        }
        final listState = ref.watch(listViewmodelProvider(data));
        return listState.when(
          data: (data) {
            return Text(data.name);
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
