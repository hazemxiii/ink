import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/extensions/string.ext.dart';
import 'package:ink/core/models/sync_queue.dart';
import 'package:ink/features/lists/data/datasources/remote_lists_datasource.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';

class SyncingViewmodel extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() async {
    final syncQueue = ref.read(syncQueueProvider);
    await syncQueue.init();
    await execute(syncQueue);
  }

  Future<void> execute(SyncQueue queue) async {
    return;
    if (await queue.isEmpty()) return;
    final remoteListsDatasource = ref.read(remoteListsDatasourceProvider);
    // final localListsDatasource = ref.read(localListsDatasourceProvider);
    for (final operation in queue.queue) {
      if (operation is CreateListOperation) {
        await remoteListsDatasource.createList(
          InkList(
            id: operation.listId,
            name: operation.name,
            color: operation.colorHex?.toColor,
            notes: [],
            createdAt: DateTime.parse(operation.isoDate),
          ),
        );
      }
    }
    queue.queue = [];
    await queue.save();
  }
}

final syncingViewmodelProvider = AsyncNotifierProvider<SyncingViewmodel, void>(
  SyncingViewmodel.new,
);
