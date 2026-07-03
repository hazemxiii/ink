import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';
import 'package:ink/features/lists/domain/usecases/watch_lists.dart';

class ListsViewmodel extends StreamNotifier<List<InkList>> {
  @override
  Stream<List<InkList>> build() async* {
    final watchLists = ref.read(watchListsProvider);
    yield* watchLists();
  }
}

final listsViewmodelProvider =
    StreamNotifierProvider<ListsViewmodel, List<InkList>>(ListsViewmodel.new);
