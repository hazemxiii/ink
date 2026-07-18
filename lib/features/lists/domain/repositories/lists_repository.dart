import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/models/sync_queue.dart';
import 'package:ink/features/lists/data/datasources/local_lists_datasource.dart';
import 'package:ink/features/lists/data/datasources/remote_lists_datasource.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';
import 'package:ink/features/lists/data/repositories/lists_repository_impl.dart';
import 'package:ink/features/notes/data/datasources/local_notes_datasource.dart';

abstract class ListsRepository {
  Stream<WatchListsStreamData> watchLists();

  Stream<WatchListStreamData> watchList(String id);

  Future<void> createList(InkList list);

  Future<InkList> updateList(InkList list);

  Future<void> deleteList(String id, {String? moveToId});

  // bool isLocalId(String id);
}

final listsRepositoryProvider = Provider<ListsRepository>(
  (ref) => ListsRepositoryImpl(
    ref.watch(remoteListsDatasourceProvider),
    ref.watch(localListsDatasourceProvider),
    ref.watch(syncQueueProvider),
    ref.watch(localNotesDatasourceProvider),
  ),
);

class WatchListStreamData {
  WatchListStreamData({required this.list, this.error, required this.done});
  final InkList list;
  final String? error;
  final bool done;
}

class WatchListsStreamData {
  WatchListsStreamData({required this.lists, required this.done, this.error});
  final List<InkList> lists;
  final bool done;
  final String? error;
}
