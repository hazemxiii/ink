import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/features/lists/domain/repositories/lists_repository.dart';

class DeleteList {
  DeleteList(this._repository);
  final ListsRepository _repository;
  Future<void> call(String id, {String? moveToId}) async {
    return await _repository.deleteList(id, moveToId: moveToId);
  }
}

final deleteListProvider = Provider<DeleteList>(
  (ref) => DeleteList(ref.watch(listsRepositoryProvider)),
);
