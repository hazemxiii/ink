import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/viewmodels/theme_viewmodel.dart';
import 'package:ink/core/widgets/ink_button.dart';
import 'package:ink/core/widgets/ink_logo.dart';
import 'package:ink/core/widgets/ink_sidebar/side_bar_list_widget.dart';
import 'package:ink/features/lists/presentation/ui/add_list_dialog/add_list_dialog.dart';
import 'package:ink/features/lists/presentation/viewmodels/lists_viewmodel.dart';
import 'package:ink/features/lists/presentation/viewmodels/selected_list_viewmodel.dart';

class InkSidebar extends ConsumerWidget {
  const InkSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeViewmodelProvider);
    final listsVieModel = ref.watch(listsViewmodelProvider);
    final selectedList = ref.watch(selectedListProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      width: 300,
      color: theme.backC,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const InkLogo(),
          Text("Your lists", style: TextStyle(color: theme.secTextC)),
          Expanded(
            child: listsVieModel.when(
              loading: () {
                return Column(
                  children: [
                    SideBarListWidget.shimmer(),
                    SideBarListWidget.shimmer(),
                    SideBarListWidget.shimmer(),
                  ],
                );
              },
              error: (error, stack) => Text(
                "Error: $error",
                style: TextStyle(color: theme.secTextC),
              ),
              data: (lists) {
                return ListView.builder(
                  itemCount: lists.length,
                  itemBuilder: (context, index) => Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    child: SideBarListWidget(
                      list: lists[index],
                      isActive: selectedList.value == lists[index].id,
                    ),
                  ),
                );
              },
            ),
          ),
          InkButton(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const AddListDialog(),
              );
            },
            text: "New list",
            icon: Icons.add,
            backC: theme.backC,
            textC: theme.secTextC,
            borderC: theme.borderC,
            // hoverTextC: theme.mainC,
            hoverBorderC: theme.mainC,
          ),
        ],
      ),
    );
  }
}
