import 'package:ink/features/notes/data/datasources/notes_datasource.dart';
import 'package:ink/features/notes/data/models/note.dart';
import 'package:ink/features/notes/data/repositories/notes_repository.dart';

class NotesRepositoryImpl implements NotesRepository {
  NotesRepositoryImpl(this.remoteNotesDatasource);
  final NotesDatasource remoteNotesDatasource;
  @override
  Future<String> create(String listId) async {
    return await remoteNotesDatasource.create(listId);
  }

  @override
  Future<Note> update(Note note) async {
    return await remoteNotesDatasource.update(note);
  }
}
