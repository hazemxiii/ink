import 'package:ink/core/exceptions/internet_ink_exception.dart';
import 'package:ink/core/models/sync_queue.dart';
import 'package:ink/features/notes/data/datasources/notes_datasource.dart';
import 'package:ink/features/notes/data/models/note.dart';
import 'package:ink/features/notes/data/repositories/notes_repository.dart';

class NotesRepositoryImpl implements NotesRepository {
  NotesRepositoryImpl(
    this.remoteNotesDatasource,
    this.localNotesDatasource,
    this.syncQueue,
  );
  final NotesDatasource remoteNotesDatasource;
  final NotesDatasource localNotesDatasource;
  final SyncQueue syncQueue;
  // TODO integrate local source
  @override
  Future<void> create(String listId, Note note) async {
    await localNotesDatasource.create(listId, note);
    try {
      await remoteNotesDatasource.create(listId, note);
    } on InternetInkException {
      //
    } catch (e) {
      await localNotesDatasource.delete(listId, note.id);
    }
  }

  @override
  Future<void> update(Note note) async {
    await remoteNotesDatasource.update(note);
  }

  @override
  Future<void> delete(String listId, String noteId) async {
    return await remoteNotesDatasource.delete(listId, noteId);
  }

  @override
  Future<Map<String, dynamic>> bulkDelete(List<String> noteIds) async {
    return await remoteNotesDatasource.bulkDelete(noteIds);
  }

  @override
  Future<Map<String, dynamic>> move(
    List<String> noteIds,
    String newListId,
  ) async {
    return await remoteNotesDatasource.move(noteIds, newListId);
  }
}
