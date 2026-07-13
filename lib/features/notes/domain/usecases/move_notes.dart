import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/features/notes/data/repositories/notes_repository.dart';

class MoveNotes {
  MoveNotes(this.notesRepository);
  final NotesRepository notesRepository;

  Future<Map<String, dynamic>> call(List<String> noteIds, String newListId) {
    return notesRepository.move(noteIds, newListId);
  }
}

final moveNotesProvider = Provider<MoveNotes>(
  (ref) => MoveNotes(ref.watch(notesRepositoryProvider)),
);
