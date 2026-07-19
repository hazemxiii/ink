import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/services/logger.dart';
import 'package:ink/core/services/prefs.dart';

class SyncQueue {
  SyncQueue({required this.prefs});

  final Prefs prefs;
  List<SyncOperation> queue = [];
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
    switch (json['type']) {
      case 'createList':
        return CreateListOperation.fromJson(json);
      case 'updateList':
        return UpdateListOperation.fromJson(json);
      case 'deleteList':
        return DeleteListOperation.fromJson(json);
      case 'upsertNote':
        return UpsertNoteOperation.fromJson(json);
      case 'deleteNote':
        return DeleteNoteOperation.fromJson(json);
      case 'bulkDeleteNote':
        return BulkDeleteNoteOperation.fromJson(json);
      case 'moveNotes':
        return MoveNotesOperation.fromJson(json);
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

class UpsertNoteOperation extends SyncOperation {
  UpsertNoteOperation({
    required this.listId,
    required this.noteId,
    required this.content,
    required this.title,
    required super.tries,
    required super.isoDate,
    required this.isNew,
  });

  factory UpsertNoteOperation.fromJson(Map<String, dynamic> json) {
    return UpsertNoteOperation(
      listId: json['listId'],
      noteId: json['noteId'],
      content: json['content'],
      title: json['title'],
      tries: json['tries'] ?? 0,
      isoDate: json['isoDate'],
      isNew: json['isNew'] ?? false,
    );
  }

  final String listId;
  final String noteId;
  final String content;
  final String title;
  final bool isNew;

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'upsertNote',
      'listId': listId,
      'noteId': noteId,
      'content': content,
      'title': title,
      'isNew': isNew,
      'tries': tries,
      'isoDate': isoDate,
    };
  }
}

class DeleteNoteOperation extends SyncOperation {
  DeleteNoteOperation({
    required this.listId,
    required this.noteId,
    required super.tries,
    required super.isoDate,
  });
  factory DeleteNoteOperation.fromJson(Map<String, dynamic> json) {
    return DeleteNoteOperation(
      listId: json['listId'],
      noteId: json['noteId'],
      tries: json['tries'] ?? 0,
      isoDate: json['isoDate'],
    );
  }
  final String listId;
  final String noteId;

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'deleteNote',
      'listId': listId,
      'noteId': noteId,
      'tries': tries,
      'isoDate': isoDate,
    };
  }
}

class BulkDeleteNoteOperation extends SyncOperation {
  BulkDeleteNoteOperation({
    required this.noteIds,
    required super.tries,
    required super.isoDate,
  });
  factory BulkDeleteNoteOperation.fromJson(Map<String, dynamic> json) {
    return BulkDeleteNoteOperation(
      noteIds: List<String>.from(json['noteIds']),
      tries: json['tries'] ?? 0,
      isoDate: json['isoDate'],
    );
  }
  final List<String> noteIds;

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'bulkDeleteNote',
      'noteIds': noteIds,
      'tries': tries,
      'isoDate': isoDate,
    };
  }
}

class MoveNotesOperation extends SyncOperation {
  MoveNotesOperation({
    required this.noteIds,
    required this.targetListId,
    required super.tries,
    required super.isoDate,
  });
  factory MoveNotesOperation.fromJson(Map<String, dynamic> json) {
    return MoveNotesOperation(
      noteIds: List<String>.from(json['noteIds']),
      targetListId: json['targetListId'],
      tries: json['tries'] ?? 0,
      isoDate: json['isoDate'],
    );
  }
  final List<String> noteIds;
  final String targetListId;

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'moveNotes',
      'noteIds': noteIds,
      'targetListId': targetListId,
      'tries': tries,
      'isoDate': isoDate,
    };
  }
}

final syncQueueProvider = Provider<SyncQueue>((ref) {
  return SyncQueue(prefs: ref.read(prefsProvider));
});
