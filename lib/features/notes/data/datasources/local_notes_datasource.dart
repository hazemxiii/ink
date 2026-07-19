import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ink/core/services/hive_service.dart';
import 'package:ink/core/services/logger.dart';
import 'package:ink/features/lists/data/models/ink_list_summary.dart';
import 'package:ink/features/notes/data/datasources/notes_datasource.dart';
import 'package:ink/features/notes/data/models/note.dart';

class LocalNotesDatasource extends NotesDatasource {
  LocalNotesDatasource({required this._notesBox, required this._listsBox});
  final Box _notesBox;
  final Box _listsBox;

  @override
  Future<Note> get(String noteId) async {
    final noteDoc = _notesBox.get(noteId);
    if (noteDoc != null) {
      Logger.log("Fetched note $noteDoc");
      return Note.fromJson(Map<String, dynamic>.from(noteDoc));
    }
    throw Exception("Note not found");
  }

  @override
  Future<Map<String, dynamic>> bulkDelete(
    String listId,
    List<String> noteIds,
  ) async {
    for (final noteId in noteIds) {
      await delete(listId, noteId);
    }
    return {};
  }

  @override
  Future<Note> create(String listId, Note note) async {
    await _notesBox.put(note.id, note.toJson());
    final listJson = _listsBox.get(listId);
    if (listJson != null) {
      final listSummary = InkListSummary.fromJson(
        Map<String, dynamic>.from(listJson),
      );
      listSummary.notesIds.add(note.id);
      await _listsBox.put(listId, listSummary.toJson());
    }
    Logger.log("Created in list $listId Note ${note.toJson()}");
    return note;
  }

  @override
  Future<void> delete(String listId, String noteId) async {
    await _notesBox.delete(noteId);
    final listDoc = _listsBox.get(listId);
    if (listDoc != null) {
      final listSummary = InkListSummary.fromJson(
        Map<String, dynamic>.from(listDoc),
      );
      listSummary.notesIds.remove(noteId);
      await _listsBox.put(listId, listSummary.toJson());
    }
    Logger.log("Deleted in list $listId Note $noteId");
  }

  @override
  Future<Map<String, dynamic>> move(
    String listId,
    List<String> noteIds,
    String newListId,
  ) async {
    for (final noteId in noteIds) {
      final note = await get(noteId);
      await create(newListId, note);
      await delete(listId, noteId);
    }
    return {};
  }

  @override
  Future<void> update(Note note) async {
    final noteDoc = _notesBox.get(note.id);
    if (noteDoc != null) {
      await _notesBox.put(note.id, note.toJson());
    }
    Logger.log("Updated Note ${note.toJson()}");
  }
}

final localNotesDatasourceProvider = Provider<LocalNotesDatasource>((ref) {
  return LocalNotesDatasource(
    notesBox: ref.read(hiveServiceProvider).notesBox,
    listsBox: ref.read(hiveServiceProvider).listsBox,
  );
});
