import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';
import 'package:ink/features/lists/domain/repositories/lists_repository.dart';

class CreateList {
  CreateList(this._repository);
  final ListsRepository _repository;
  Future<InkList> call(InkList list) async {
    return await _repository.createList(list);
  }
}

final createListProvider = Provider<CreateList>(
  (ref) => CreateList(ref.watch(listsRepositoryProvider)),
);
