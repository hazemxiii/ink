import 'package:ink/features/lists/data/datasources/lists_datasource.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';
import 'package:ink/features/lists/domain/repositories/lists_repository.dart';

class ListsRepositoryImpl extends ListsRepository {
  ListsRepositoryImpl(this._remoteListsDatasource);
  final ListsDatasource _remoteListsDatasource;
  @override
  Future<InkList> createList(InkList list) {
    // TODO: implement createList
    throw UnimplementedError();
  }

  @override
  Future<void> deleteList(String id, {String? moveToId}) {
    // TODO: implement deleteList
    throw UnimplementedError();
  }

  @override
  Future<InkList> getList(String id) async {
    return await _remoteListsDatasource.getList(id);
  }

  @override
  Future<InkList> updateList(InkList list) {
    // TODO: implement updateList
    throw UnimplementedError();
  }

  @override
  Stream<List<InkList>> watchLists() async* {
    final lists = await _remoteListsDatasource.getLists();
    yield lists;
  }
}
