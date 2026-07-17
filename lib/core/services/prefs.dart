import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/models/sync_queue.dart';
import 'package:ink/core/models/theme/ink_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  Prefs() {
    prefs = SharedPreferencesAsync();
  }
  late SharedPreferencesAsync prefs;

  Future<void> setQueue(List<SyncOperation> operations) async {
    await prefs.setStringList("queue", operations.map(jsonEncode).toList());
  }

  Future<List<SyncOperation>> getQueue() async {
    final queue = await prefs.getStringList("queue") ?? [];
    return queue
        .map(
          (op) =>
              SyncOperation.fromJson(Map<String, dynamic>.from(jsonDecode(op))),
        )
        .toList();
  }

  Future<void> setStartupList(String? id) async {
    if (id == null) {
      await prefs.remove('startup_list');
      return;
    }
    await prefs.setString('startup_list', id);
  }

  Future<String?> getStartupList() async {
    return await prefs.getString('startup_list');
  }

  Future<void> setTheme(InkThemeType theme) async {
    late final String themeString;
    switch (theme) {
      case InkThemeType.dark:
        themeString = "dark";
        break;
      case InkThemeType.light:
        themeString = "light";
        break;
      case InkThemeType.system:
        themeString = "system";
        break;
    }
    await prefs.setString('theme', themeString);
  }

  Future<InkThemeType> getTheme() async {
    final theme = await prefs.getString('theme') ?? "system";
    late final InkThemeType themeType;
    switch (theme) {
      case "dark":
        themeType = InkThemeType.dark;
        break;
      case "light":
        themeType = InkThemeType.light;
        break;
      case "system":
        themeType = InkThemeType.system;
        break;
    }
    return themeType;
  }
}

final prefsProvider = Provider<Prefs>((ref) => Prefs());
