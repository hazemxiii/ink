import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/features/notes/data/repositories/notes_repository.dart';

class DeleteNote {
  DeleteNote(this._notesRepository);
  final NotesRepository _notesRepository;

  Future<void> call(String listId, String noteId) async {
    return await _notesRepository.delete(listId, noteId);
  }
}

final deleteNoteProvider = Provider<DeleteNote>((ref) {
  return DeleteNote(ref.read(notesRepositoryProvider));
});
