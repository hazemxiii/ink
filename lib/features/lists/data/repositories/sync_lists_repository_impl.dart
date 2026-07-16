// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:ink/core/models/sync_queue.dart';
// import 'package:ink/core/services/logger.dart';
// import 'package:ink/features/lists/data/datasources/lists_datasource.dart';
// import 'package:ink/features/lists/data/datasources/local_lists_datasource.dart';
// import 'package:ink/features/lists/data/datasources/remote_lists_datasource.dart';
// import 'package:ink/features/lists/data/models/ink_list.dart';
// import 'package:ink/features/lists/domain/repositories/lists_repository.dart';

// class SyncListsRepositoryImpl extends ListsRepository {
//   SyncListsRepositoryImpl({
//     required this._remoteDatasource,
//     required this._localDatasource,
//   });
//   final ListsDatasource _remoteDatasource;
//   final ListsDatasource _localDatasource;

//   @override
//   Future<InkList> createList(InkList list) async {
//     return await _remoteDatasource.createList(list);
//   }

//   @override
//   Future<void> deleteList(String id, {String? moveToId}) async {
//     await _remoteDatasource.deleteList(id, moveToId: moveToId);
//   }

//   @override
//   Future<InkList> updateList(InkList list) async {
//     return await _remoteDatasource.updateList(list);
//   }

//   @override
//   Stream<InkList> watchList(String id) {
//     throw UnimplementedError();
//   }

//   @override
//   Stream<WatchListsStreamData> watchLists() {
//     throw UnimplementedError();
//   }

//   Future<void> syncData(IdsMapper mapper) async {
//     Logger.log("Syncing lists from the server");
//     final remoteLists = await _remoteDatasource.getLists();
//     final localLists = await _localDatasource.getLists();
//     for (final remoteList in remoteLists) {
//       final InkList localList = localLists.firstWhere(
//         (list) =>
//             list.id == remoteList.id ||
//             mapper.localToRemote[list.id] == remoteList.id,
//         orElse: InkList.empty,
//       );
//       if (localList.id.isEmpty) {
//         await _localDatasource.createList(remoteList);
//       } else {
//         await _localDatasource.updateList(remoteList);
//         await _localDatasource.deleteList(localList.id);
//       }
//     }
//     Logger.log("[END] Syncing lists from the server");
//   }
// }

// final syncListsReopsitoryProvider = Provider<SyncListsRepositoryImpl>((ref) {
//   return SyncListsRepositoryImpl(
//     remoteDatasource: ref.read(remoteListsDatasourceProvider),
//     localDatasource: ref.read(localListsDatasourceProvider),
//   );
// });
