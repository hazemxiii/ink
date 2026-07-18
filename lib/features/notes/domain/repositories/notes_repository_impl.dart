import 'package:ink/core/exceptions/internet_ink_exception.dart';
import 'package:ink/core/models/sync_queue.dart';
import 'package:ink/features/notes/data/datasources/notes_datasource.dart';
import 'package:ink/features/notes/data/models/note.dart';
import 'package:ink/features/notes/data/repositories/notes_repository.dart';

// TODO sync
class NotesRepositoryImpl implements NotesRepository {
  NotesRepositoryImpl(
    this.remoteNotesDatasource,
    this.localNotesDatasource,
    this.syncQueue,
  );
  final NotesDatasource remoteNotesDatasource;
  final NotesDatasource localNotesDatasource;
  final SyncQueue syncQueue;
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
    final oldNote = await localNotesDatasource.get(note.id);
    await localNotesDatasource.update(note);
    try {
      await remoteNotesDatasource.update(note);
    } on InternetInkException {
      //
    } catch (e) {
      await localNotesDatasource.update(oldNote);
    }
  }

  @override
  Future<void> delete(String listId, String noteId) async {
    try {
      await localNotesDatasource.delete(listId, noteId);
      await remoteNotesDatasource.delete(listId, noteId);
    } on InternetInkException {
      //
    } catch (e) {
      //
    }
  }

  @override
  Future<Map<String, dynamic>> bulkDelete(
    String listId,
    List<String> noteIds,
  ) async {
    try {
      await localNotesDatasource.bulkDelete(listId, noteIds);
      return await remoteNotesDatasource.bulkDelete(listId, noteIds);
    } on InternetInkException {
      //
      return {};
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> move(
    String listId,
    List<String> noteIds,
    String newListId,
  ) async {
    try {
      await localNotesDatasource.move(listId, noteIds, newListId);
      return await remoteNotesDatasource.move(newListId, noteIds, newListId);
    } on InternetInkException {
      //
      return {};
    } catch (e) {
      rethrow;
    }
  }
}
