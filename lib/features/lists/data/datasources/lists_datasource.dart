import 'package:ink/features/lists/data/models/ink_list.dart';

abstract class ListsDatasource {
  Future<List<InkList>> getListsWithoutNotes();
  Future<InkList> getList(String id);
  Future<InkList> createList(InkList list);
  Future<InkList> updateList(InkList list);
  Future<void> deleteList(String id, {String? moveToId});
}
