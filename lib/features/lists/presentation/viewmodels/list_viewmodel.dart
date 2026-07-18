import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';
import 'package:ink/features/lists/domain/repositories/lists_repository.dart';
import 'package:ink/features/lists/domain/usecases/delete_list.dart';
import 'package:ink/features/lists/domain/usecases/get_list.dart';
import 'package:ink/features/lists/domain/usecases/update_list.dart';
import 'package:ink/features/notes/data/models/note.dart';
import 'package:ink/features/notes/domain/usecases/bulk_delete_notes.dart';
import 'package:ink/features/notes/domain/usecases/create_note.dart';
import 'package:ink/features/notes/domain/usecases/delete_note.dart';
import 'package:ink/features/notes/domain/usecases/move_notes.dart';
import 'package:ink/features/notes/domain/usecases/update_note.dart';

class ListViewmodel extends StreamNotifier<WatchListStreamData> {
  ListViewmodel(this.id);
  final String id;
  @override
  Stream<WatchListStreamData> build() async* {
    final getList = ref.read(getListProvider);
    yield* getList(id);
  }

  Future<void> updateList(InkList list) async {
    final updateList = ref.read(updateListProvider);
    await updateList(list);
    state = AsyncValue.data(
      WatchListStreamData(list: list, done: state.value?.done ?? false),
    );
  }

  Future<void> deleteList({String? moveToListId}) async {
    await ref.read(deleteListProvider)(id, moveToId: moveToListId);
  }

  Future<Note> createNote(Note note) async {
    await ref.read(createNoteProvider)(id, note);
    state = AsyncValue.data(
      WatchListStreamData(
        list: state.value!.list.copyWith(
          notes: [...state.value!.list.notes, note],
        ),
        done: state.value!.done,
      ),
    );
    return note;
  }

  Future<void> updateNote(Note note) async {
    final updateNote = ref.read(updateNoteProvider);
    await updateNote(note);
    state = AsyncValue.data(
      WatchListStreamData(
        list: state.value!.list.copyWith(
          notes: state.value!.list.notes
              .map((e) => e.id == note.id ? note : e)
              .toList(),
        ),
        done: state.value!.done,
      ),
    );
  }

  Future<void> deleteNote(String noteId) async {
    await ref.read(deleteNoteProvider)(id, noteId);
    state = AsyncValue.data(
      WatchListStreamData(
        list: state.value!.list.copyWith(
          notes: state.value!.list.notes.where((e) => e.id != noteId).toList(),
        ),
        done: state.value!.done,
      ),
    );
  }

  Future<Map<String, dynamic>> bulkDeleteNotes(List<String> noteIds) async {
    final bulkDeleteNotes = ref.read(bulkDeleteNotesProvider);
    final result = await bulkDeleteNotes(id, noteIds);
    final success = List<String>.from(result['deletedNotes'] ?? []);
    state = AsyncValue.data(
      WatchListStreamData(
        list: state.value!.list.copyWith(
          notes: state.value!.list.notes
              .where((e) => !success.contains(e.id))
              .toList(),
        ),
        done: state.value!.done,
      ),
    );
    return result;
  }

  Future<Map<String, dynamic>> move(
    List<String> noteIds,
    String newListId,
  ) async {
    final moveNotes = ref.read(moveNotesProvider);
    final result = await moveNotes(id, noteIds, newListId);
    final success = List<String>.from(result['movedNotes'] ?? []);
    state = AsyncValue.data(
      WatchListStreamData(
        list: state.value!.list.copyWith(
          notes: state.value!.list.notes
              .where((e) => !success.contains(e.id))
              .toList(),
        ),
        done: state.value!.done,
      ),
    );
    return result;
  }
}

final listViewmodelProvider =
    StreamNotifierProvider.family<ListViewmodel, WatchListStreamData, String>(
      ListViewmodel.new,
    );
