import 'dart:convert';

import 'package:ink/core/exceptions/ink_exception.dart';
import 'package:ink/core/services/api_service.dart';
import 'package:ink/core/services/sync_queue_service.dart';
import 'package:ink/features/lists/data/datasources/lists_datasource.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';
import 'package:ink/features/lists/domain/repositories/lists_repository.dart';

class ListsRepositoryImpl extends ListsRepository {
  ListsRepositoryImpl(
    this._remoteListsDatasource,
    this._localListsDatasource,
    this._syncQueue,
  );
  final ListsDatasource _remoteListsDatasource;
  final ListsDatasource _localListsDatasource;
  final SyncQueueService _syncQueue;
  @override
  Future<InkList> createList(InkList list) async {
    InkList? remoteList;
    final localId = "local-${DateTime.now().toIso8601String()}";
    try {
      throw InkException("testing");
      remoteList = await _remoteListsDatasource.createList(list);
    } catch (e) {
      _syncQueue.add(
        SyncRequest(
          resource: 'lists',
          method: Methods.post,
          bodyJson: jsonEncode(list.copyWith(id: localId)),
        ),
      );
    }
    return await _localListsDatasource.createList(
      remoteList ?? list.copyWith(id: localId),
    );
  }

  @override
  Future<void> deleteList(String id, {String? moveToId}) async {
    if (!isLocalId(id)) {
      try {
        await _remoteListsDatasource.deleteList(id, moveToId: moveToId);
      } catch (e) {
        _syncQueue.add(
          SyncRequest(
            resource:
                'lists/$id${moveToId != null ? '?move_to_id=$moveToId' : ''}',
            method: Methods.delete,
          ),
        );
      }
    }
    await _localListsDatasource.deleteList(id, moveToId: moveToId);
    // TODO handle offline move
  }

  @override
  Stream<InkList> watchList(String id) async* {
    try {
      yield await _localListsDatasource.getList(id);
      if (!isLocalId(id)) {
        yield await _remoteListsDatasource.getList(id);
      }
    } catch (e) {
      //
    }
  }

  @override
  Future<InkList> updateList(InkList list) async {
    await _localListsDatasource.updateList(list);
    InkList? remoteList;
    try {
      remoteList = await _remoteListsDatasource.updateList(list);
    } catch (e) {
      _syncQueue.add(
        SyncRequest(
          resource: 'lists/${list.id}',
          method: Methods.patch,
          bodyJson: jsonEncode(list.toJson()),
        ),
      );
    }
    if (remoteList != null) {
      await _localListsDatasource.updateList(remoteList);
    }
    return remoteList ?? list;
  }

  @override
  Stream<WatchListsStreamData> watchLists() async* {
    late final List<InkList> localLists;
    try {
      localLists = await _localListsDatasource.getLists();
      yield WatchListsStreamData(lists: localLists, done: false);
    } catch (e) {
      yield WatchListsStreamData(
        lists: [],
        done: false,
        error: "Failed to get local data: ${e.toString()}",
      );
    }
    // await Future.delayed(const Duration(seconds: 3));
    try {
      final lists = await _remoteListsDatasource.getLists();
      yield WatchListsStreamData(
        lists: [...lists, ...localLists.where((l) => isLocalId(l.id))],
        done: true,
      );
    } catch (e) {
      yield WatchListsStreamData(
        lists: localLists,
        done: true,
        error: "Failed to get data from the internet: ${e.toString()}",
      );
    }
  }

  @override
  bool isLocalId(String id) {
    return id.startsWith("local-");
  }
}
