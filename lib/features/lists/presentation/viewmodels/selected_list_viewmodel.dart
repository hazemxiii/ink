import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/services/prefs.dart';

class SelectedListViewModel extends AsyncNotifier<String?> {
  SelectedListViewModel({required this.prefs});
  Prefs prefs;

  @override
  Future<String?> build() async {
    final id = await prefs.getStartupList();
    return id;
  }

  Future<void> selectList(String? id) async {
    state = AsyncValue.data(id);
    await prefs.setStartupList(id);
  }
}

final selectedListProvider =
    AsyncNotifierProvider<SelectedListViewModel, String?>(
      () => SelectedListViewModel(prefs: Prefs()),
      dependencies: [prefsProvider],
    );
