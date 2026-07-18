import 'package:ink/features/notes/data/models/note.dart';

abstract class NotesDatasource {
  Future<Note> get(String noteId);
  Future<void> create(String listId, Note note);
  Future<void> update(Note note);
  Future<void> delete(String listId, String noteId);
  Future<Map<String, dynamic>> bulkDelete(String listId, List<String> noteIds);
  Future<Map<String, dynamic>> move(
    String listId,
    List<String> noteIds,
    String newListId,
  );
}
