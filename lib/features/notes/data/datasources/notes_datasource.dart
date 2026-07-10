import 'package:ink/features/notes/data/models/note.dart';

abstract class NotesDatasource {
  Future<String> create(String listId);
  Future<Note> update(Note note);
}
