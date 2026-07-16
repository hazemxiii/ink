import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';
import 'package:ink/features/lists/domain/repositories/lists_repository.dart';
import 'package:ink/features/lists/domain/usecases/create_list.dart';
import 'package:ink/features/lists/domain/usecases/update_list.dart';
import 'package:ink/features/lists/domain/usecases/watch_lists.dart';

class ListsViewmodel extends StreamNotifier<WatchListsStreamData> {
  @override
  Stream<WatchListsStreamData> build() async* {
    final watchLists = ref.read(watchListsProvider);
    yield* watchLists();
  }

  Future<void> addList(InkList list) async {
    final createList = ref.read(createListProvider);
    final oldValue = [...(state.value?.lists ?? <InkList>[])];
    state = AsyncValue.data(
      WatchListsStreamData(lists: [...oldValue, list], done: true),
    );
    try {
      await createList(list);
    } catch (e) {
      state = AsyncValue.data(
        WatchListsStreamData(lists: oldValue, done: true),
      );
      rethrow;
    }
  }

  Future<void> updateList(InkList list) async {
    final oldValue = [...(state.value?.lists ?? <InkList>[])];
    state = AsyncValue.data(
      WatchListsStreamData(
        lists: oldValue.map((e) => e.id == list.id ? list : e).toList(),
        done: true,
      ),
    );
    final updateList = ref.read(updateListProvider);
    try {
      await updateList(list);
    } catch (e) {
      state = AsyncValue.data(
        WatchListsStreamData(lists: oldValue, done: true),
      );
      rethrow;
    }
  }
}

final listsViewmodelProvider =
    StreamNotifierProvider<ListsViewmodel, WatchListsStreamData>(
      ListsViewmodel.new,
    );
