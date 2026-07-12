import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/models/theme/ink_theme.dart';
import 'package:toastification/toastification.dart';

class InkToastService {
  void showErrorToast(
    BuildContext context,
    InkTheme theme,
    String title,
    String message,
  ) {
    toastification.show(
      context: context,
      backgroundColor: theme.boxesBackC,
      foregroundColor: theme.textC,
      borderSide: BorderSide(color: theme.errorC),
      alignment: Alignment.bottomRight,
      type: ToastificationType.error,
      autoCloseDuration: const Duration(seconds: 3),
      title: Text(
        title,
        style: TextStyle(color: theme.errorC, fontWeight: FontWeight.bold),
      ),
      description: Text(message),
    );
  }
}

final inkToastServiceProvider = Provider<InkToastService>(
  (ref) => InkToastService(),
);
