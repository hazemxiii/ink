import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ink/core/services/logger.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox('lists');
    await Hive.openBox('notes');

    // await delete();
  }

  static Future<void> delete() async {
    Logger.log('Deleting boxes');
    await Hive.box('lists').clear();
    await Hive.box('notes').clear();
  }

  Box get listsBox => Hive.box('lists');
  Box get notesBox => Hive.box('notes');
}

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});
