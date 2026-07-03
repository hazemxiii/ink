import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';
import 'package:ink/features/lists/domain/repositories/lists_repository.dart';

class GetLists {
  GetLists(this._repository);
  final ListsRepository _repository;
  Stream<List<InkList>> call() {
    return _repository.watchLists();
  }
}

final watchListsProvider = Provider<GetLists>(
  (ref) => GetLists(ref.watch(listsRepositoryProvider)),
);
