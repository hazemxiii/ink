import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/models/select_option_item.dart';
import 'package:ink/core/viewmodels/theme_viewmodel.dart';

class SelectOptionsWidget extends ConsumerStatefulWidget {
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
  ConsumerState<SelectOptionsWidget> createState() =>
      _SelectOptionsWidgetState();
}

class _SelectOptionsWidgetState extends ConsumerState<SelectOptionsWidget> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
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
            '${widget.selectedCount} selected',
            style: TextStyle(color: theme.secTextC),
          ),
          const SizedBox(width: 4),
          DecoratedBox(
            decoration: BoxDecoration(color: theme.secTextC),
            child: const SizedBox(width: 1, height: 16),
          ),
          const SizedBox(width: 4),
          IgnorePointer(
            ignoring: widget.selectedCount == 0,
            child: Opacity(
              opacity: widget.selectedCount == 0 ? 0.5 : 1.0,
              child: Row(
                children: [
                  ...widget.options.map(
                    (option) => IconButton(
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        await option.onTap();
                        setState(() {
                          _isLoading = false;
                        });
                      },
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
          if (_isLoading)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.mainC,
              ),
            )
          else
            IconButton(
              onPressed: widget.onCancel,
              icon: Icon(Icons.close, color: theme.mainC),
            ),
        ],
      ),
    );
  }
}
