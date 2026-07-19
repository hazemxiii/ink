import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/features/notes/data/repositories/notes_repository.dart';

class MoveNotes {
  MoveNotes(this.notesRepository);
  final NotesRepository notesRepository;

  Future<void> call(
    String listId,
    List<String> noteIds,
    String newListId,
  ) async {
    return await notesRepository.move(listId, noteIds, newListId);
  }
}

final moveNotesProvider = Provider<MoveNotes>(
  (ref) => MoveNotes(ref.watch(notesRepositoryProvider)),
);
