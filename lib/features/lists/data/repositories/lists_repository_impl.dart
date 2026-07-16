import 'package:ink/core/exceptions/ink_exception.dart';
import 'package:ink/core/exceptions/internet_ink_exception.dart';
import 'package:ink/features/lists/data/datasources/lists_datasource.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';
import 'package:ink/features/lists/domain/repositories/lists_repository.dart';

class ListsRepositoryImpl extends ListsRepository {
  ListsRepositoryImpl(
    this._remoteListsDatasource,
    this._localListsDatasource,
    // this._syncQueue,
  );
  final ListsDatasource _remoteListsDatasource;
  final ListsDatasource _localListsDatasource;
  // final SyncQueue _syncQueue;
  @override
  Future<void> createList(InkList list) async {
    await _localListsDatasource.createList(list);
    try {
      throw InkException("You're GAY");
      await _remoteListsDatasource.createList(list);
    } on InternetInkException {
      //  TODO sync
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
    yield await _localListsDatasource.getList(id);
  }

  @override
  Future<InkList> updateList(InkList list) async {
    final oldList = await _localListsDatasource.getList(list.id);
    await _localListsDatasource.updateList(list);
    try {
      throw InkException("You're Lesbian");
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
    final List<InkList> localLists = await _localListsDatasource.getLists();
    yield WatchListsStreamData(lists: localLists, done: true);
  }
}
