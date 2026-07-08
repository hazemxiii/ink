import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';
import 'package:ink/features/lists/domain/usecases/get_list.dart';
import 'package:ink/features/lists/domain/usecases/update_list.dart';

class ListViewmodel extends AsyncNotifier<InkList> {
  ListViewmodel(this.id);
  final String id;
  @override
  FutureOr<InkList> build() async {
    final getList = ref.read(getListProvider);
    return await getList(id);
  }

  Future<void> updateList(InkList list) async {
    state = await AsyncValue.guard(() async {
      final updateList = ref.read(updateListProvider);
      return await updateList(list);
    });
  }
}

final listViewmodelProvider =
    AsyncNotifierProvider.family<ListViewmodel, InkList, String>(
      ListViewmodel.new,
    );
