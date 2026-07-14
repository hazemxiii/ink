import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/models/theme/ink_dark_theme.dart';
import 'package:ink/core/models/theme/ink_light_theme.dart';
import 'package:ink/core/models/theme/ink_theme.dart';
import 'package:ink/core/services/prefs.dart';

class ThemeViewmodel extends Notifier<InkTheme> {
  late final Prefs _prefs;
  @override
  InkTheme build() {
    _loadTheme();
    return InkLightTheme();
  }

  bool get isDark => state is InkDarkTheme;

  Future<void> _loadTheme() async {
    _prefs = ref.read(prefsProvider);
    final prefs = await _prefs.getTheme();

    state = prefs == InkThemeType.dark ? InkDarkTheme() : InkLightTheme();
  }

  void setTheme(InkTheme theme) {
    state = theme;
    _prefs.setTheme(
      theme is InkDarkTheme ? InkThemeType.dark : InkThemeType.light,
    );
  }

  void toggleTheme() {
    if (isDark) {
      setTheme(InkLightTheme());
    } else {
      setTheme(InkDarkTheme());
    }
  }
}

final themeViewmodelProvider = NotifierProvider<ThemeViewmodel, InkTheme>(
  ThemeViewmodel.new,
);
