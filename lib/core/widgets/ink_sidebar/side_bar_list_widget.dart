import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/viewmodels/theme_viewmodel.dart';
import 'package:ink/core/widgets/ink_button.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';
import 'package:ink/features/lists/presentation/ui/add_list_dialog/add_list_dialog.dart';
import 'package:ink/features/lists/presentation/viewmodels/selected_list_viewmodel.dart';
import 'package:shimmer/shimmer.dart';

class SideBarListWidget extends ConsumerStatefulWidget {
  const SideBarListWidget({
    super.key,
    this.isActive = false,
    required this.list,
  }) : isShimmer = false;
  SideBarListWidget.shimmer({super.key})
    : isActive = false,
      list = InkList.empty(),
      isShimmer = true;
  final InkList list;
  final bool isActive;
  final bool isShimmer;

  @override
  ConsumerState<SideBarListWidget> createState() => _SideBarListWidgetState();
}

class _SideBarListWidgetState extends ConsumerState<SideBarListWidget> {
  bool _hovered = false;
  bool get _isMobile {
    if (kIsWeb) {
      return false;
    }
    if (Platform.isAndroid || Platform.isIOS) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final selectedListController = ref.read(selectedListProvider.notifier);
    if (widget.isShimmer) return _shimmer();
    final theme = ref.watch(themeViewmodelProvider);
    return InkWell(
      onTap: () {
        selectedListController.selectList(widget.list.id);
      },
      onHover: (value) => setState(() {
        _hovered = value;
      }),
      child: Container(
        height: 40,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: widget.isActive ? theme.mainC : Colors.transparent,
          ),
          color: (_hovered || widget.isActive)
              ? theme.boxesBackC
              : Colors.transparent,
        ),
        child: Row(
          spacing: 5,
          children: [
            CircleAvatar(
              radius: 4,
              backgroundColor: widget.list.color ?? Colors.transparent,
            ),
            Text(
              widget.list.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: widget.isActive ? theme.textC : theme.secTextC,
              ),
            ),
            const Spacer(),
            if (_hovered || _isMobile) ...[
              Transform.scale(
                scale: 0.8,
                child: InkButton(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AddListDialog(list: widget.list);
                      },
                    );
                  },
                  backC: Colors.transparent,
                  textC: theme.mainC,
                  hoverBackC: Colors.transparent,
                  icon: Icons.edit_outlined,
                  padding: EdgeInsets.zero,
                ),
              ),
              Transform.scale(
                scale: 0.8,
                child: InkButton(
                  onTap: () {},
                  backC: Colors.transparent,
                  textC: theme.errorC,
                  hoverBackC: Colors.transparent,
                  icon: Icons.delete_outline,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _shimmer() {
    final theme = ref.watch(themeViewmodelProvider);
    return Container(
      padding: const EdgeInsets.all(8),
      width: double.infinity,
      child: Shimmer.fromColors(
        baseColor: theme.boxesBackC,
        highlightColor: theme.backC,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: theme.boxesBackC,
          ),
          child: const Text("data"),
        ),
      ),
    );
  }
}
