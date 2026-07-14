import 'package:ink/features/lists/data/datasources/lists_datasource.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';
import 'package:ink/features/lists/domain/repositories/lists_repository.dart';

class ListsRepositoryImpl extends ListsRepository {
  ListsRepositoryImpl(this._remoteListsDatasource, this._localListsDatasource);
  final ListsDatasource _remoteListsDatasource;
  final ListsDatasource _localListsDatasource;
  @override
  Future<InkList> createList(InkList list) async {
    InkList? remoteList;
    try {
      remoteList = await _remoteListsDatasource.createList(list);
    } catch (e) {
      //
    }
    // TODO sync operations
    return await _localListsDatasource.createList(
      remoteList ?? list.copyWith(id: DateTime.now().toIso8601String()),
    );
  }

  @override
  Future<void> deleteList(String id, {String? moveToId}) async {
    try {
      await _localListsDatasource.deleteList(id);
    } catch (e) {
      //
    }
    return await _remoteListsDatasource.deleteList(id, moveToId: moveToId);
  }

  @override
  Stream<InkList> watchList(String id) async* {
    try {
      final list = await _localListsDatasource.getList(id);
      yield list;
    } catch (e) {
      //
    }
    yield await _remoteListsDatasource.getList(id);
  }

  @override
  Future<InkList> updateList(InkList list) async {
    late final InkList remoteList;
    try {
      remoteList = await _remoteListsDatasource.updateList(list);
    } catch (e) {
      //
    }
    return await _localListsDatasource.updateList(remoteList);
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
      yield WatchListsStreamData(lists: lists, done: true);
    } catch (e) {
      yield WatchListsStreamData(
        lists: localLists,
        done: true,
        error: "Failed to get data from the internet: ${e.toString()}",
      );
    }
  }
}
