import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/exceptions/internet_ink_exception.dart';
import 'package:ink/core/extensions/string.ext.dart';
import 'package:ink/core/models/sync_queue.dart';
import 'package:ink/core/services/logger.dart';
import 'package:ink/features/lists/data/datasources/remote_lists_datasource.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';
import 'package:ink/features/notes/data/datasources/remote_notes_datasource.dart';
import 'package:ink/features/notes/data/models/note.dart';

class SyncingViewmodel extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() async {
    final syncQueue = ref.read(syncQueueProvider);
    await syncQueue.init();
    await execute(syncQueue);
  }

  Future<void> execute(SyncQueue queue) async {
    if (await queue.isEmpty()) return;
    final remoteListsDatasource = ref.read(remoteListsDatasourceProvider);
    final remoteNotesDatasource = ref.read(remoteNotesDatasourceProvider);
    final newState = [...queue.queue];
    // final localListsDatasource = ref.read(localListsDatasourceProvider);
    for (final operation in queue.queue) {
      try {
        if (operation is CreateListOperation) {
          await remoteListsDatasource.createList(
            InkList(
              id: operation.listId,
              name: operation.name,
              color: operation.colorHex?.toColor,
              notes: [],
              createdAt: DateTime.parse(operation.isoDate),
              updatedAt: DateTime.now().toUtc(),
            ),
          );
        } else if (operation is UpdateListOperation) {
          await remoteListsDatasource.updateList(
            InkList(
              id: operation.listId,
              name: operation.name,
              color: operation.colorHex?.toColor,
              notes: [],
              createdAt: DateTime.now().toUtc(),
              updatedAt: DateTime.parse(operation.isoDate),
            ),
          );
        } else if (operation is DeleteListOperation) {
          await remoteListsDatasource.deleteList(operation.listId);
        } else if (operation is UpsertNoteOperation) {
          final note = Note(
            id: operation.noteId,
            title: operation.title,
            content: operation.content,
            createdAt: DateTime.parse(operation.isoDate),
            updatedAt: DateTime.parse(operation.isoDate),
          );
          if (operation.isNew) {
            await remoteNotesDatasource.create(operation.listId, note);
          } else {
            await remoteNotesDatasource.update(note);
          }
        }
        newState.remove(operation);
      } on InternetInkException {
        operation.tries++;
        if (operation.tries >= 3) {
          newState.remove(operation);
        }
        break;
      } catch (e) {
        newState.remove(operation);
        Logger.log('Error executing operation: $e');
      }
    }
    queue.queue = newState;
    Logger.log('Queue after execution: ${queue.queue.map((e) => e.toJson())}');
    await queue.save();
  }
}

final syncingViewmodelProvider = AsyncNotifierProvider<SyncingViewmodel, void>(
  SyncingViewmodel.new,
);
