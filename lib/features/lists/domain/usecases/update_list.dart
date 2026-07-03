import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';
import 'package:ink/features/lists/domain/repositories/lists_repository.dart';

class UpdateList {
  UpdateList(this._repository);
  final ListsRepository _repository;
  Future<InkList> call(InkList list) async {
    return await _repository.updateList(list);
  }
}

final updateListProvider = Provider<UpdateList>(
  (ref) => UpdateList(ref.watch(listsRepositoryProvider)),
);
