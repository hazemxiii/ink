import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';
import 'package:ink/features/lists/domain/repositories/lists_repository.dart';

class GetList {
  GetList(this._repository);
  final ListsRepository _repository;
  Stream<InkList> call(String id) {
    return _repository.watchList(id);
  }
}

final getListProvider = Provider<GetList>(
  (ref) => GetList(ref.watch(listsRepositoryProvider)),
);
