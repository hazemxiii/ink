import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/features/notes/data/datasources/remote_notes_datasource.dart';
import 'package:ink/features/notes/data/repositories/notes_repository_impl.dart';

abstract class NotesRepository {
  Future<String> create(String listId);
}

final notesRepositoryProvider = Provider<NotesRepository>(
  (ref) => NotesRepositoryImpl(ref.watch(remoteNotesDatasourceProvider)),
);
