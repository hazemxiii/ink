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
    final resultList = await createList(list);
    state = AsyncValue.data(
      WatchListsStreamData(
        lists: [...state.value!.lists, resultList],
        done: state.value!.done,
      ),
    );
  }

  Future<void> updateList(InkList list) async {
    final updateList = ref.read(updateListProvider);
    final resultList = await updateList(list);
    state = AsyncValue.data(
      WatchListsStreamData(
        lists: state.value!.lists
            .map((e) => e.id == list.id ? resultList : e)
            .toList(),
        done: state.value!.done,
      ),
    );
  }
}

final listsViewmodelProvider =
    StreamNotifierProvider<ListsViewmodel, WatchListsStreamData>(
      ListsViewmodel.new,
    );
