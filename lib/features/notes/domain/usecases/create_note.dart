import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/features/notes/data/models/note.dart';
import 'package:ink/features/notes/data/repositories/notes_repository.dart';

class CreateNote {
  CreateNote(this.notesRepository);
  final NotesRepository notesRepository;
  Future<void> call(String listId, Note note) async {
    await notesRepository.create(listId, note);
  }
}

final createNoteProvider = Provider<CreateNote>(
  (ref) => CreateNote(ref.watch(notesRepositoryProvider)),
);
