import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:ink/core/exceptions/ink_exception.dart';
import 'package:ink/core/services/hive_service.dart';
import 'package:ink/core/services/logger.dart';
import 'package:ink/features/lists/data/datasources/lists_datasource.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';
import 'package:ink/features/lists/data/models/ink_list_summary.dart';
import 'package:ink/features/notes/data/models/note.dart';
import 'package:ink/features/notes/data/models/note_summary.dart';

class LocalListsDatasource extends ListsDatasource {
  LocalListsDatasource({required this.listsBox, required this.notesBox});
  final Box listsBox;
  final Box notesBox;

  @override
  Future<InkList> createList(InkList list) async {
    try {
      Logger.log("creating or updating list: ${list.toJson()} locally");
      await listsBox.put(list.id, InkListSummary.fromParent(list).toJson());
      return list;
    } catch (e) {
      throw InkException("Unexpected Error");
    }
  }

  @override
  Future<void> deleteList(String id, {String? moveToId}) async {
    try {
      Logger.log("deleting list: $id locally");
      final list = await getList(id);
      if (moveToId != null) {
        final notes = list.notes;
        InkList moveTo = await getList(moveToId);
        moveTo = moveTo.copyWith(notes: [...moveTo.notes, ...notes]);
        await updateList(moveTo);
        for (final note in notes) {
          notesBox.put(
            note.id,
            NoteSummary.fromNote(note, listId: moveToId).toJson(),
          );
        }
      } else {
        for (final note in list.notes) {
          notesBox.delete(note.id);
        }
      }
      listsBox.delete(id);
    } catch (e) {
      throw InkException("Unexpected Error");
    }
  }

  @override
  Future<InkList> getList(String id) async {
    try {
      final listDoc = listsBox.get(id);
      if (listDoc == null) {
        throw InkException("List $id not found");
      }
      final listJson = Map<String, dynamic>.from(listDoc);
      final listSummary = InkListSummary.fromJson(listJson);
      final notes = <Note>[];
      for (final noteId in listSummary.notesIds) {
        final noteJson = notesBox.get(noteId);
        notes.add(Note.fromJson(noteJson));
      }
      final localList = InkList(
        id: listSummary.id,
        name: listSummary.name,
        color: listSummary.color,
        notes: notes,
        createdAt: listSummary.createdAt,
        updatedAt: listSummary.updatedAt,
      );
      Logger.log("local list: ${localList.toJson()}");
      return localList;
    } catch (e) {
      throw InkException("Unexpected Error");
    }
  }

  @override
  Future<List<InkList>> getListsWithoutNotes() async {
    try {
      final lists = listsBox.values
          .map((e) => InkListSummary.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      final localLists = lists
          .map(
            (l) => InkList(
              id: l.id,
              name: l.name,
              color: l.color,
              notes: [],
              createdAt: l.createdAt,
              updatedAt: l.updatedAt,
            ),
          )
          .toList();

      Logger.log("local lists: ${localLists.map((e) => e.toJson()).toList()}");
      return localLists;
    } catch (e) {
      throw InkException("Unexpected Error");
    }
  }

  @override
  Future<InkList> updateList(InkList list) async {
    return await createList(list);
  }
}

final localListsDatasourceProvider = Provider<LocalListsDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  return LocalListsDatasource(
    listsBox: hiveService.listsBox,
    notesBox: hiveService.notesBox,
  );
});
