import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/viewmodels/theme_viewmodel.dart';
import 'package:ink/core/widgets/ink_button.dart';
import 'package:ink/core/widgets/text_input.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';
import 'package:ink/features/lists/presentation/ui/add_list_dialog/color_picker_row.dart';
import 'package:ink/features/lists/presentation/viewmodels/list_viewmodel.dart';
import 'package:ink/features/lists/presentation/viewmodels/lists_viewmodel.dart';

class AddListDialog extends ConsumerStatefulWidget {
  const AddListDialog({super.key, this.list});
  final InkList? list;

  @override
  ConsumerState<AddListDialog> createState() => _AddListDialogState();
}

class _AddListDialogState extends ConsumerState<AddListDialog> {
  final TextEditingController _nameController = TextEditingController();
  late Color _selectedColor;
  bool get _isEditing => widget.list != null;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.list?.color ?? Colors.white;
    if (_isEditing) {
      _nameController.text = widget.list!.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeViewmodelProvider);
    return AlertDialog(
      constraints: const BoxConstraints(maxWidth: 400),
      backgroundColor: theme.backC,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.borderC),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 5, backgroundColor: _selectedColor),
              const SizedBox(width: 8),
              Text(
                "Name your list",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.textC,
                ),
              ),
            ],
          ),
          Text(
            "A list is a container for notes — and soon, more. Give it a name you'll recognize at a glance.",
            style: TextStyle(color: theme.secTextC, fontSize: 16),
          ),
          TextInput(
            textInputAction: TextInputAction.done,
            onSubmitted: (v) => _onSubmit(),
            controller: _nameController,
            label: "List name",
            textC: theme.mainC,
          ),
          ColorPickerRow(
            selectedColor: _selectedColor,
            onColorChanged: (c) {
              setState(() {
                _selectedColor = c;
              });
            },
          ),
          InkButton(
            onTap: _onSubmit,
            text: _isEditing ? "Save" : "Create",
            backC: theme.mainC,
            textC: theme.textC,
            isLoading: _isLoading,
          ),
          if (_error != null)
            Text(
              _error!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
        ],
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (_isLoading) return;
    if (_nameController.text.isEmpty) {
      setState(() {
        _error = "List name cannot be empty";
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      if (_isEditing) {
        await ref
            .read(listViewmodelProvider(widget.list!.id).notifier)
            .updateList(
              widget.list!.copyWith(
                name: _nameController.text,
                color: _selectedColor,
              ),
            );
      } else {
        await ref
            .read(listsViewmodelProvider.notifier)
            .addList(
              InkList(
                name: _nameController.text,
                color: _selectedColor,
                id: '',
                notes: [],
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
    setState(() {
      _isLoading = false;
    });
  }
}
