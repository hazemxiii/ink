import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';
import 'package:ink/features/lists/domain/usecases/create_list.dart';
import 'package:ink/features/lists/domain/usecases/update_list.dart';
import 'package:ink/features/lists/domain/usecases/watch_lists.dart';

class ListsViewmodel extends StreamNotifier<List<InkList>> {
  @override
  Stream<List<InkList>> build() async* {
    final watchLists = ref.read(watchListsProvider);
    yield* watchLists();
  }

  Future<void> addList(InkList list) async {
    final createList = ref.read(createListProvider);
    final resultList = await createList(list);
    state = AsyncValue.data([...state.value!, resultList]);
  }

  Future<void> updateList(InkList list) async {
    final updateList = ref.read(updateListProvider);
    final resultList = await updateList(list);
    state = AsyncValue.data(
      state.value!.map((e) => e.id == list.id ? resultList : e).toList(),
    );
  }

  Future<void> createNote() async {
    // TODO implement
  }
}

final listsViewmodelProvider =
    StreamNotifierProvider<ListsViewmodel, List<InkList>>(ListsViewmodel.new);
