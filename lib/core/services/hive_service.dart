import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox('lists');
    await Hive.openBox('notes');

    // await delete();

    debugPrint('===================Lists box===================');
    debugPrint(Hive.box("lists").toMap().toString());
    debugPrint('===================Notes box===================');
    debugPrint(Hive.box("notes").toMap().toString());
  }

  static Future<void> delete() async {
    await Hive.box('lists').clear();
    await Hive.box('notes').clear();
  }

  Box get listsBox => Hive.box('lists');
  Box get notesBox => Hive.box('notes');
}

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});
