import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/models/sync_queue.dart';
import 'package:ink/features/notes/data/datasources/local_notes_datasource.dart';
import 'package:ink/features/notes/data/datasources/remote_notes_datasource.dart';
import 'package:ink/features/notes/data/models/note.dart';
import 'package:ink/features/notes/domain/repositories/notes_repository_impl.dart';

abstract class NotesRepository {
  Future<void> create(String listId, Note note);
  Future<void> update(Note note);
  Future<void> delete(String listId, String noteId);
  Future<void> bulkDelete(String listId, List<String> noteIds);
  Future<void> move(String listId, List<String> noteIds, String newListId);
}

final notesRepositoryProvider = Provider<NotesRepository>(
  (ref) => NotesRepositoryImpl(
    ref.watch(remoteNotesDatasourceProvider),
    ref.watch(localNotesDatasourceProvider),
    ref.watch(syncQueueProvider),
  ),
);
