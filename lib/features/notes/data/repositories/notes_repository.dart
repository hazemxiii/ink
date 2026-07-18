import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/features/notes/data/datasources/remote_notes_datasource.dart';
import 'package:ink/features/notes/data/models/note.dart';
import 'package:ink/features/notes/domain/repositories/notes_repository_impl.dart';

abstract class NotesRepository {
  Future<void> create(String listId, Note note);
  Future<void> update(Note note);
  Future<void> delete(String noteId);
  Future<Map<String, dynamic>> bulkDelete(List<String> noteIds);
  Future<Map<String, dynamic>> move(List<String> noteIds, String newListId);
}

final notesRepositoryProvider = Provider<NotesRepository>(
  (ref) => NotesRepositoryImpl(ref.watch(remoteNotesDatasourceProvider)),
);
