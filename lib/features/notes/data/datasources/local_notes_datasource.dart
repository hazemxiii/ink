import 'package:ink/features/notes/data/datasources/notes_datasource.dart';
import 'package:ink/features/notes/data/models/note.dart';

class LocalNotesDatasource extends NotesDatasource {
  @override
  Future<Map<String, dynamic>> bulkDelete(List<String> noteIds) {
    // TODO: implement bulkDelete
    throw UnimplementedError();
  }

  @override
  Future<String> create(String listId) {
    // TODO: implement create
    throw UnimplementedError();
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
