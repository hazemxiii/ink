import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/viewmodels/theme_viewmodel.dart';
import 'package:ink/features/lists/presentation/ui/list_page/list_section.dart';
import 'package:ink/features/lists/presentation/viewmodels/list_viewmodel.dart';
import 'package:ink/features/lists/presentation/viewmodels/lists_viewmodel.dart';
import 'package:ink/features/lists/presentation/viewmodels/selected_list_viewmodel.dart';

class ListPage extends ConsumerWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeViewmodelProvider);
    final selectedList = ref.watch(selectedListProvider);
    return selectedList.when(
      data: (listId) {
        if (listId == null) {
          final listsState = ref.watch(listsViewmodelProvider);
          return listsState.when(
            data: (lists) {
              if (lists.lists.isEmpty) {
                return Center(
                  child: Text("No lists", style: TextStyle(color: theme.textC)),
                );
              }
              final listState = ref.watch(
                listViewmodelProvider(lists.lists.first.id),
              );
              return listState.when(
                data: (data) {
                  return ListSection(list: data.list);
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
        final listState = ref.watch(listViewmodelProvider(listId));
        return listState.when(
          data: (data) {
            return ListSection(list: data.list);
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
