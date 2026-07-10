import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/features/notes/data/repositories/notes_repository.dart';

class CreateNote {
  CreateNote(this.notesRepository);
  final NotesRepository notesRepository;
  Future<String> call(String listId) async {
    return await notesRepository.create(listId);
  }
}

final createNoteProvider = Provider<CreateNote>(
  (ref) => CreateNote(ref.watch(notesRepositoryProvider)),
);
