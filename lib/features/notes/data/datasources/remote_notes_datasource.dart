import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/exceptions/ink_exception.dart';
import 'package:ink/core/services/api_service.dart';
import 'package:ink/core/services/logger.dart';
import 'package:ink/features/notes/data/datasources/notes_datasource.dart';
import 'package:ink/features/notes/data/models/note.dart';

class RemoteNotesDatasource extends NotesDatasource {
  RemoteNotesDatasource(this.apiService);
  final ApiService apiService;
  @override
  Future<Note> create(String listId, Note note) async {
    final noteData = await apiService.post("notes", {
      "id": note.id,
      "listId": listId,
      "title": note.title,
      "content": note.content,
    });
    return Note.fromJson(noteData);
  }

  @override
  Future<Note> update(Note note) async {
    final json = await apiService.patch("notes/${note.id}", {
      "title": note.title,
      "content": note.content,
    });
    try {
      return Note.fromJson(json);
    } catch (e) {
      Logger.log(e.toString());
      throw InkException("Unexpected Error");
    }
  }

  @override
  Future<void> delete(String noteId) async {
    return await apiService.delete("notes/$noteId");
  }

  @override
  Future<Map<String, dynamic>> bulkDelete(List<String> noteIds) async {
    final response = await apiService.post("notes/bulk-delete", {
      "ids": noteIds,
    });
    final result = response as Map<String, dynamic>;
    try {
      return result;
    } catch (e) {
      Logger.log(e.toString());
      throw InkException("Unexpected Error");
    }
  }

  @override
  Future<Map<String, dynamic>> move(
    List<String> noteIds,
    String newListId,
  ) async {
    final response = await apiService.post("notes/move", {
      "ids": noteIds,
      "listId": newListId,
    });
    final result = response as Map<String, dynamic>;
    try {
      return result;
    } catch (e) {
      Logger.log(e.toString());
      throw InkException("Unexpected Error");
    }
  }
}

final remoteNotesDatasourceProvider = Provider<NotesDatasource>(
  (ref) => RemoteNotesDatasource(ref.watch(apiServiceProvider)),
);
