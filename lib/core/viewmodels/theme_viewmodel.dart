import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/models/theme/ink_dark_theme.dart';
import 'package:ink/core/models/theme/ink_theme.dart';

class ThemeViewmodel extends Notifier<InkTheme> {
  @override
  InkTheme build() {
    return InkDarkTheme();
  }
}

final themeViewmodelProvider = NotifierProvider<ThemeViewmodel, InkTheme>(
  ThemeViewmodel.new,
);
