import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/features/lists/data/datasources/remote_lists_datasource.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';
import 'package:ink/features/lists/data/repositories/lists_repository_impl.dart';

abstract class ListsRepository {
  Stream<List<InkList>> watchLists();

  Stream<InkList> watchList(String id);

  Future<InkList> createList(InkList list);

  Future<InkList> updateList(InkList list);

  Future<void> deleteList(String id, {String? moveToId});
}

final listsRepositoryProvider = Provider<ListsRepository>(
  (ref) => ListsRepositoryImpl(ref.watch(remoteListsDatasourceProvider)),
);
