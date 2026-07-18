import 'package:ink/features/notes/data/models/note.dart';

abstract class NotesDatasource {
  Future<void> create(String listId, Note note);
  Future<void> update(Note note);
  Future<void> delete(String listId, String noteId);
  Future<Map<String, dynamic>> bulkDelete(List<String> noteIds);
  Future<Map<String, dynamic>> move(List<String> noteIds, String newListId);
}
