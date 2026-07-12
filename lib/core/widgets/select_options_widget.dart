import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/models/select_option_item.dart';
import 'package:ink/core/viewmodels/theme_viewmodel.dart';

class SelectOptionsWidget extends ConsumerWidget {
  const SelectOptionsWidget({
    super.key,
    required this.selectedCount,
    required this.options,
    required this.onCancel,
  });
  final int selectedCount;
  final List<SelectOptionItem> options;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeViewmodelProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.boxesBackC,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.borderC),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$selectedCount selected',
            style: TextStyle(color: theme.secTextC),
          ),
          const SizedBox(width: 4),
          DecoratedBox(
            decoration: BoxDecoration(color: theme.secTextC),
            child: const SizedBox(width: 1, height: 16),
          ),
          const SizedBox(width: 4),
          IgnorePointer(
            ignoring: selectedCount == 0,
            child: Opacity(
              opacity: selectedCount == 0 ? 0.5 : 1.0,
              child: Row(
                children: [
                  ...options.map(
                    (option) => IconButton(
                      onPressed: option.onTap,
                      icon: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 3,
                        children: [
                          Icon(option.icon, color: option.color),
                          Text(
                            option.text,
                            style: TextStyle(color: option.color),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: onCancel,
            icon: Icon(Icons.close, color: theme.mainC),
          ),
        ],
      ),
    );
  }
}
