import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';
import 'package:ink/features/lists/domain/usecases/get_list.dart';
import 'package:ink/features/lists/domain/usecases/update_list.dart';
import 'package:ink/features/notes/data/models/note.dart';
import 'package:ink/features/notes/domain/usecases/create_note.dart';
import 'package:ink/features/notes/domain/usecases/delete_note.dart';
import 'package:ink/features/notes/domain/usecases/update_note.dart';

class ListViewmodel extends StreamNotifier<InkList> {
  ListViewmodel(this.id);
  final String id;
  @override
  Stream<InkList> build() {
    final getList = ref.read(getListProvider);
    return getList(id);
  }

  Future<void> updateList(InkList list) async {
    final updateList = ref.read(updateListProvider);
    await updateList(list);
    state = AsyncValue.data(list.copyWith(notes: state.value!.notes));
  }

  Future<String> createNote() async {
    final noteId = await ref.read(createNoteProvider)(id);
    state = AsyncValue.data(
      state.value!.copyWith(
        notes: [
          ...state.value!.notes,
          Note(
            id: noteId,
            title: '',
            content: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
      ),
    );
    return noteId;
  }

  Future<void> updateNote(Note note) async {
    final updateNote = ref.read(updateNoteProvider);
    final updatedNote = await updateNote(note);
    state = AsyncValue.data(
      state.value!.copyWith(
        notes: state.value!.notes
            .map((e) => e.id == note.id ? updatedNote : e)
            .toList(),
      ),
    );
  }
  
  Future<void> deleteNote(String noteId) async {
    final deleteNote = ref.read(deleteNoteProvider); 
    await deleteNote(noteId);
    state = AsyncValue.data(
      state.value!.copyWith(
        notes: state.value!.notes
            .where((e) => e.id != noteId)
            .toList(),
      ),
    );
  }
}

final listViewmodelProvider =
    StreamNotifierProvider.family<ListViewmodel, InkList, String>(
      ListViewmodel.new,
    );
