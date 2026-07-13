import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/features/notes/data/datasources/remote_notes_datasource.dart';
import 'package:ink/features/notes/data/models/note.dart';
import 'package:ink/features/notes/domain/repositories/notes_repository_impl.dart';

abstract class NotesRepository {
  Future<String> create(String listId);
  Future<Note> update(Note note);
  Future<void> delete(String noteId);
  Future<Map<String, dynamic>> bulkDelete(List<String> noteIds);
}

final notesRepositoryProvider = Provider<NotesRepository>(
  (ref) => NotesRepositoryImpl(ref.watch(remoteNotesDatasourceProvider)),
);
