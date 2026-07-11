import 'package:ink/features/lists/data/datasources/lists_datasource.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';
import 'package:ink/features/lists/domain/repositories/lists_repository.dart';

class ListsRepositoryImpl extends ListsRepository {
  ListsRepositoryImpl(this._remoteListsDatasource);
  final ListsDatasource _remoteListsDatasource;
  @override
  Future<InkList> createList(InkList list) async {
    return await _remoteListsDatasource.createList(list);
  }

  @override
  Future<void> deleteList(String id, {String? moveToId}) async {
    return await _remoteListsDatasource.deleteList(id, moveToId: moveToId);
  }

  @override
  Stream<InkList> watchList(String id) async*{
    yield await _remoteListsDatasource.getList(id);
  }

  @override
  Future<InkList> updateList(InkList list) async {
    return await _remoteListsDatasource.updateList(list);
  }

  @override
  Stream<List<InkList>> watchLists() async* {
    final lists = await _remoteListsDatasource.getLists();
    yield lists;
  }
}
