import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/features/lists/domain/repositories/lists_repository.dart';

class GetList {
  GetList(this._repository);
  final ListsRepository _repository;
  Stream<WatchListStreamData> call(String id) {
    return _repository.watchList(id);
  }
}

final getListProvider = Provider<GetList>(
  (ref) => GetList(ref.watch(listsRepositoryProvider)),
);
