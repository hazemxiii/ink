import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/features/notes/data/models/note.dart';
import 'package:ink/features/notes/data/repositories/notes_repository.dart';

class UpdateNote {
  UpdateNote(this.notesRepository);
  final NotesRepository notesRepository;
  Future<void> call(Note note) async {
    return await notesRepository.update(note);
  }
}

final updateNoteProvider = Provider<UpdateNote>(
  (ref) => UpdateNote(ref.read(notesRepositoryProvider)),
);
