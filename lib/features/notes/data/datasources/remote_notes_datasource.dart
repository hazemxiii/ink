import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/services/api_service.dart';
import 'package:ink/features/notes/data/datasources/notes_datasource.dart';

class RemoteNotesDatasource extends NotesDatasource {
  RemoteNotesDatasource(this.apiService);
  final ApiService apiService;
  @override
  Future<String> create(String listId) async {
    final note = await apiService.post("api/lists/$listId/notes", {});
    // TODO create note
    return note['id'];
  }
}

final remoteNotesDatasourceProvider = Provider<NotesDatasource>(
  (ref) => RemoteNotesDatasource(ref.watch(apiServiceProvider)),
);
