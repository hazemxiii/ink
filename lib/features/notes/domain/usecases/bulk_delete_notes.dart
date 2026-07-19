import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/features/notes/data/repositories/notes_repository.dart';

class BulkDeleteNotes {
  BulkDeleteNotes(this.repository);
  final NotesRepository repository;

  Future<void> call(String listId, List<String> noteIds) async {
    return await repository.bulkDelete(listId, noteIds);
  }
}

final bulkDeleteNotesProvider = Provider<BulkDeleteNotes>((ref) {
  return BulkDeleteNotes(ref.read(notesRepositoryProvider));
});
