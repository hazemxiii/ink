import 'package:ink/core/exceptions/internet_ink_exception.dart';
import 'package:ink/core/extensions/color.ext.dart';
import 'package:ink/core/models/sync_queue.dart';
import 'package:ink/features/lists/data/datasources/lists_datasource.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';
import 'package:ink/features/lists/domain/repositories/lists_repository.dart';
import 'package:ink/features/notes/data/datasources/notes_datasource.dart';

class ListsRepositoryImpl extends ListsRepository {
  ListsRepositoryImpl(
    this._remoteListsDatasource,
    this._localListsDatasource,
    this._syncQueue,
    // this._localNotesDatasource,
  );
  final ListsDatasource _remoteListsDatasource;
  final ListsDatasource _localListsDatasource;
  // final NotesDatasource _localNotesDatasource;
  final SyncQueue _syncQueue;
  @override
  Future<void> createList(InkList list) async {
    await _localListsDatasource.createList(list);
    try {
      throw InternetInkException("Test");
      await _remoteListsDatasource.createList(list);
    } on InternetInkException {
      await _syncQueue.addOperation(
        CreateListOperation(
          listId: list.id,
          name: list.name,
          colorHex: list.color?.toHex,
          tries: 0,
          isoDate: list.createdAt.toUtc().toIso8601String(),
        ),
      );
    } catch (e) {
      await _localListsDatasource.deleteList(list.id);
      rethrow;
    }
  }

  @override
  Future<void> deleteList(String id, {String? moveToId}) async {
    await _localListsDatasource.deleteList(id, moveToId: moveToId);
    try {
      await _remoteListsDatasource.deleteList(id, moveToId: moveToId);
    } on InternetInkException {
      // TODO sync
    } catch (e) {
      rethrow;
    }
  }

  @override
  Stream<InkList> watchList(String id) async* {
    final localList = await _localListsDatasource.getList(id);
    yield localList;
    await Future.delayed(Duration(seconds: 3));
    final remoteList = await _remoteListsDatasource.getList(id);
    final remoteNotes = remoteList.notes;
    final localNotes = localList.notes;

    final localIds = localNotes.map((note) => note.id).toSet();
    final remoteIds = remoteNotes.map((note) => note.id).toSet();

    for (final id in localIds) {}

    yield remoteList;
  }

  @override
  Future<InkList> updateList(InkList list) async {
    final oldList = await _localListsDatasource.getList(list.id);
    await _localListsDatasource.updateList(list);
    try {
      await _remoteListsDatasource.updateList(list);
    } on InternetInkException {
      // TODO sync
    } catch (e) {
      await _localListsDatasource.updateList(oldList);
      rethrow;
    }
    return list;
  }

  @override
  Stream<WatchListsStreamData> watchLists() async* {
    final List<InkList> localLists = await _localListsDatasource
        .getListsWithoutNotes();
    bool done = true;
    if (await _syncQueue.isEmpty()) {
      done = false;
    }
    yield WatchListsStreamData(lists: localLists, done: done);
    final Set<String> processedListIds = {};
    if (!done) {
      final remoteLists = await _remoteListsDatasource.getListsWithoutNotes();
      for (final list in remoteLists) {
        try {
          await _localListsDatasource.getList(list.id);
          await _localListsDatasource.updateList(list);
        } catch (e) {
          await _localListsDatasource.createList(list);
        }
        processedListIds.add(list.id);
      }
      for (final list in localLists) {
        if (!processedListIds.contains(list.id)) {
          _localListsDatasource.deleteList(list.id);
        }
      }
      yield WatchListsStreamData(lists: remoteLists, done: true);
    }
  }
}
