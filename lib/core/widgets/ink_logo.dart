import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/viewmodels/theme_viewmodel.dart';

class InkLogo extends ConsumerWidget {
  const InkLogo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeViewmodelProvider);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      spacing: 5,
      children: [
        CircleAvatar(radius: 5, backgroundColor: theme.mainC),
        Text(
          "ink",
          style: TextStyle(
            color: theme.textC,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
