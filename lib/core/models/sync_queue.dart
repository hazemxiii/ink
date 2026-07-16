// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:ink/core/extensions/string.ext.dart';
// import 'package:ink/core/services/logger.dart';
// import 'package:ink/core/services/prefs.dart';
// import 'package:ink/features/lists/data/models/ink_list.dart';
// import 'package:ink/features/lists/data/repositories/sync_lists_repository_impl.dart';
// import 'package:ink/features/lists/domain/repositories/lists_repository.dart';

// class SyncQueue {
//   SyncQueue({required this.prefs, required this.listsRepository});

//   final Prefs prefs;
//   final ListsRepository listsRepository;
//   late final IdsMapper idsMapper;
//   late final List<SyncOperation> queue;

//   Future<void> init() async {
//     idsMapper = IdsMapper();
//     queue = [];
//   }

//   Future<void> addOperation(SyncOperation operation) async {
//     Logger.log("adding operation: ${operation.toJson()}");
//     queue.add(operation);
//     await save();
//   }

//   Future<void> execute() async {
//     final queueCopy = [...queue];
//     for (final operation in queueCopy) {
//       Logger.log("syncing operation: ${operation.toJson()}");
//       operation.execute(idsMapper, listsRepository: listsRepository);
//       if (operation is ListSyncOperation) {
//         if (operation is CreateListOperation) {
//           // final remoteList = await listsRepository.createList(
//           //   InkList(
//           //     id: operation.listId,
//           //     name: operation.name,
//           //     color: operation.colorHex?.toColor,
//           //     notes: [],
//           //     createdAt: DateTime.now(),
//           //     updatedAt: DateTime.now(),
//           //   ),
//           // );
//           // idsMapper.addMapping(operation.listId, remoteList.id);
//         } else if (operation is UpdateListOperation) {
//           // if (idsMapper.isLocal(operation.listId) &&
//           //     idsMapper.localToRemote[operation.listId] == null) {
//           //   break;
//           // }
//           // final remoteListId = idsMapper.localToRemote[operation.listId];
//           // await listsRepository.updateList(
//           //   InkList(
//           //     id: remoteListId!,
//           //     name: operation.name,
//           //     color: operation.colorHex?.toColor,
//           //     notes: [],
//           //     createdAt: DateTime.now(),
//           //     updatedAt: DateTime.now(),
//           //   ),
//           // );
//         } else if (operation is DeleteListOperation) {
//           // if (idsMapper.isLocal(operation.listId) &&
//           //     idsMapper.localToRemote[operation.listId] == null) {
//           //   break;
//           // }
//           // if (operation.moveToId != null) {
//           //   if (idsMapper.isLocal(operation.moveToId!) &&
//           //       idsMapper.localToRemote[operation.moveToId!] == null) {
//           //     break;
//           //   }
//           // }
//           // final remoteListId = idsMapper.localToRemote[operation.listId];
//           // await listsRepository.deleteList(
//           //   remoteListId!,
//           //   moveToId: operation.moveToId != null
//           //       ? idsMapper.localToRemote[operation.moveToId!]
//           //       : null,
//           // );
//         }
//       }
//       queue.remove(operation);
//     }
//     await (listsRepository as SyncListsRepositoryImpl).syncData(idsMapper);
//   }

//   Future<void> save() async {
//     // TODO: Save queue to prefs
//   }

//   bool isLocalId(String id) {
//     return idsMapper.isLocal(id);
//   }
// }

// class IdsMapper {
//   Map<String, String> localToRemote = {};
//   Map<String, String> remoteToLocal = {};

//   void addMapping(String localId, String remoteId) {
//     localToRemote[localId] = remoteId;
//     remoteToLocal[remoteId] = localId;
//   }

//   String? getRemoteId(String localId) {
//     return localToRemote[localId];
//   }

//   String? getLocalId(String remoteId) {
//     return remoteToLocal[remoteId];
//   }

//   bool isLocal(String id) {
//     return id.startsWith("local-");
//   }
// }

// abstract class SyncOperation {
//   Map<String, dynamic> toJson();
//   Future<void> execute(IdsMapper mapper, {ListsRepository? listsRepository});
// }

// abstract class ListSyncOperation extends SyncOperation {}

// class CreateListOperation extends ListSyncOperation {
//   CreateListOperation({
//     required this.listId,
//     required this.name,
//     required this.colorHex,
//   });
//   final String listId;
//   final String name;
//   final String? colorHex;

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'type': 'createList',
//       'listId': listId,
//       'name': name,
//       'colorHex': colorHex,
//     };
//   }

//   @override
//   Future<void> execute(
//     IdsMapper mapper, {
//     ListsRepository? listsRepository,
//   }) async {
//     final remoteList = await listsRepository!.createList(
//       InkList(
//         id: listId,
//         name: name,
//         color: colorHex?.toColor,
//         notes: [],
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//     );
//     mapper.addMapping(listId, remoteList.id);
//   }
// }

// class UpdateListOperation extends ListSyncOperation {
//   UpdateListOperation({
//     required this.listId,
//     required this.name,
//     this.colorHex,
//   });
//   final String listId;
//   final String name;
//   final String? colorHex;

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'type': 'updateList',
//       'listId': listId,
//       'name': name,
//       'colorHex': colorHex,
//     };
//   }

//   @override
//   Future<void> execute(
//     IdsMapper mapper, {
//     ListsRepository? listsRepository,
//   }) async {
//     if (mapper.isLocal(listId) && mapper.localToRemote[listId] == null) {
//       return;
//     }
//     final remoteListId = mapper.localToRemote[listId];
//     await listsRepository!.updateList(
//       InkList(
//         id: remoteListId!,
//         name: name,
//         color: colorHex?.toColor,
//         notes: [],
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//     );
//   }
// }

// class DeleteListOperation extends ListSyncOperation {
//   DeleteListOperation({required this.listId, this.moveToId});
//   final String listId;
//   final String? moveToId;

//   @override
//   Map<String, dynamic> toJson() {
//     return {'type': 'deleteList', 'listId': listId, 'moveToId': moveToId};
//   }

//   @override
//   Future<void> execute(
//     IdsMapper mapper, {
//     ListsRepository? listsRepository,
//   }) async {
//     if (mapper.isLocal(listId) && mapper.localToRemote[listId] == null) {
//       return;
//     }
//     if (moveToId != null) {
//       if (mapper.isLocal(moveToId!) &&
//           mapper.localToRemote[moveToId!] == null) {
//         return;
//       }
//     }
//     final remoteListId = mapper.localToRemote[listId];
//     await listsRepository!.deleteList(
//       remoteListId!,
//       moveToId: moveToId != null ? mapper.localToRemote[moveToId!] : null,
//     );
//   }
// }

// final syncQueueProvider = Provider<SyncQueue>((ref) {
//   return SyncQueue(
//     prefs: ref.read(prefsProvider),
//     listsRepository: ref.read(syncListsReopsitoryProvider),
//   );
// });
