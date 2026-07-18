import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ink/core/services/hive_service.dart';
import 'package:ink/core/services/logger.dart';
import 'package:ink/features/notes/data/datasources/notes_datasource.dart';
import 'package:ink/features/notes/data/models/note.dart';

class LocalNotesDatasource extends NotesDatasource {
  LocalNotesDatasource({required this._notesBox, required this._listsBox});
  final Box _notesBox;
  final Box _listsBox;

  @override
  Future<Map<String, dynamic>> bulkDelete(List<String> noteIds) {
    // TODO: implement bulkDelete
    throw UnimplementedError();
  }

  @override
  Future<Note> create(String listId, Note note) async {
    await _notesBox.put(note.id, note);
    final list = _listsBox.get(listId);
    if (list != null) {
      list.notes.add(note.id);
      await _listsBox.put(listId, list);
    }
    Logger.log("Created in list $listId Note ${note.id}");
    return note;
  }

  @override
  Future<void> delete(String noteId) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> move(List<String> noteIds, String newListId) {
    // TODO: implement move
    throw UnimplementedError();
  }

  @override
  Future<Note> update(Note note) {
    // TODO: implement update
    throw UnimplementedError();
  }
}

final localNotesDatasourceProvider = Provider<LocalNotesDatasource>((ref) {
  return LocalNotesDatasource(
    notesBox: ref.read(hiveServiceProvider).notesBox,
    listsBox: ref.read(hiveServiceProvider).listsBox,
  );
});
