import 'package:ink/core/exceptions/internet_ink_exception.dart';
import 'package:ink/core/models/sync_queue.dart';
import 'package:ink/features/notes/data/datasources/notes_datasource.dart';
import 'package:ink/features/notes/data/models/note.dart';
import 'package:ink/features/notes/data/repositories/notes_repository.dart';

// TODO move & delete notes error
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
      syncQueue.addOperation(
        UpsertNoteOperation(
          listId: listId,
          noteId: note.id,
          content: note.content,
          title: note.title,
          tries: 0,
          isoDate: DateTime.now().toUtc().toIso8601String(),
          isNew: true,
        ),
      );
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
      syncQueue.addOperation(
        UpsertNoteOperation(
          listId: "listId",
          noteId: note.id,
          content: note.content,
          title: note.title,
          tries: 0,
          isoDate: DateTime.now().toUtc().toIso8601String(),
          isNew: false,
        ),
      );
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
      syncQueue.addOperation(
        DeleteNoteOperation(
          listId: listId,
          noteId: noteId,
          tries: 0,
          isoDate: DateTime.now().toUtc().toIso8601String(),
        ),
      );
    } catch (e) {
      //
    }
  }

  @override
  Future<void> bulkDelete(String listId, List<String> noteIds) async {
    try {
      await localNotesDatasource.bulkDelete(listId, noteIds);
      await remoteNotesDatasource.bulkDelete(listId, noteIds);
    } on InternetInkException {
      syncQueue.addOperation(
        BulkDeleteNoteOperation(
          noteIds: noteIds,
          tries: 0,
          isoDate: DateTime.now().toUtc().toIso8601String(),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> move(
    String listId,
    List<String> noteIds,
    String newListId,
  ) async {
    try {
      await localNotesDatasource.move(listId, noteIds, newListId);
      await remoteNotesDatasource.move(newListId, noteIds, newListId);
    } on InternetInkException {
      syncQueue.addOperation(
        MoveNotesOperation(
          noteIds: noteIds,
          targetListId: newListId,
          tries: 0,
          isoDate: DateTime.now().toUtc().toIso8601String(),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
}
