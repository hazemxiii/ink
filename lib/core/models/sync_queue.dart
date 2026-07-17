import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/services/logger.dart';
import 'package:ink/core/services/prefs.dart';

class SyncQueue {
  SyncQueue({required this.prefs});

  final Prefs prefs;
  late final List<SyncOperation> queue;
  bool _initCalled = false;

  Future<void> init() async {
    if (_initCalled) return;
    _initCalled = true;
    queue = await prefs.getQueue();
    Logger.log("loaded sync queue: ${queue.map((e) => e.toJson()).toList()}");
  }

  Future<void> addOperation(SyncOperation operation) async {
    if (!_initCalled) {
      await init();
    }
    Logger.log("adding to sync queue: ${operation.toJson()}");
    queue.add(operation);
    await save();
  }

  Future<void> save() async {
    if (!_initCalled) {
      await init();
    }
    await prefs.setQueue(queue);
  }

  Future<bool> isEmpty() async {
    if (!_initCalled) {
      await init();
    }
    return queue.isEmpty;
  }
}

abstract class SyncOperation {
  SyncOperation({required this.tries, required this.isoDate});
  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    json['isoDate'] = DateTime.now().toUtc().toIso8601String();
    switch (json['type']) {
      case 'createList':
        return CreateListOperation.fromJson(json);
      case 'updateList':
        return UpdateListOperation.fromJson(json);
      case 'deleteList':
        return DeleteListOperation.fromJson(json);
      default:
        throw UnimplementedError();
    }
  }
  Map<String, dynamic> toJson();

  final String isoDate;
  int tries;
}

class CreateListOperation extends SyncOperation {
  CreateListOperation({
    required this.listId,
    required this.name,
    required this.colorHex,
    required super.tries,
    required super.isoDate,
  });
  factory CreateListOperation.fromJson(Map<String, dynamic> json) {
    return CreateListOperation(
      listId: json['listId'],
      name: json['name'],
      colorHex: json['colorHex'],
      tries: json['tries'] ?? 0,
      isoDate: json['isoDate'],
    );
  }
  final String listId;
  final String name;
  final String? colorHex;

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'createList',
      'listId': listId,
      'name': name,
      'colorHex': colorHex,
      'tries': tries,
      'isoDate': isoDate,
    };
  }
}

class UpdateListOperation extends SyncOperation {
  UpdateListOperation({
    required this.listId,
    required this.name,
    this.colorHex,
    required super.tries,
    required super.isoDate,
  });
  factory UpdateListOperation.fromJson(Map<String, dynamic> json) {
    return UpdateListOperation(
      listId: json['listId'],
      name: json['name'],
      colorHex: json['colorHex'],
      tries: json['tries'] ?? 0,
      isoDate: json['isoDate'],
    );
  }
  final String listId;
  final String name;
  final String? colorHex;

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'updateList',
      'listId': listId,
      'name': name,
      'colorHex': colorHex,
      'tries': tries,
      'isoDate': isoDate,
    };
  }
}

class DeleteListOperation extends SyncOperation {
  DeleteListOperation({
    required this.listId,
    this.moveToId,
    required super.tries,
    required super.isoDate,
  });
  factory DeleteListOperation.fromJson(Map<String, dynamic> json) {
    return DeleteListOperation(
      listId: json['listId'],
      moveToId: json['moveToId'],
      tries: json['tries'] ?? 0,
      isoDate: json['isoDate'],
    );
  }
  final String listId;
  final String? moveToId;

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'deleteList',
      'listId': listId,
      'moveToId': moveToId,
      'tries': tries,
      'isoDate': isoDate,
    };
  }
}

final syncQueueProvider = Provider<SyncQueue>((ref) {
  return SyncQueue(prefs: ref.read(prefsProvider));
});
