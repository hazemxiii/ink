import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/exceptions/ink_exception.dart';
import 'package:ink/core/extensions/color.ext.dart';
import 'package:ink/core/services/api_service.dart';
import 'package:ink/features/lists/data/datasources/lists_datasource.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';

class RemoteListsDatasource extends ListsDatasource {
  RemoteListsDatasource(this._apiService);
  final ApiService _apiService;

  @override
  Future<InkList> createList(InkList list) async {
    final json = await _apiService.post("lists", {
      "name": list.name,
      if (list.color != null) "color": list.color!.toHex,
    });
    try {
      return InkList.fromJson(json);
    } catch (e) {
      debugPrint(e.toString());
      debugPrintStack();
      throw InkException("Unexpected Error");
    }
  }

  @override
  Future<void> deleteList(String id, {String? moveToId}) {
    // TODO: implement deleteList
    throw UnimplementedError();
  }

  @override
  Future<InkList> getList(String id) async {
    final json = await _apiService.get("lists/$id");
    try {
      return InkList.fromJson(json);
    } catch (e) {
      debugPrint(e.toString());
      debugPrintStack();
      throw InkException("Unexpected Error");
    }
  }

  @override
  Future<InkList> updateList(InkList list) async {
    final json = await _apiService.patch("lists/${list.id}", {
      "name": list.name,
      if (list.color != null) "color": list.color!.toHex,
    });
    try {
      json['notes'] = [];
      return InkList.fromJson(json);
    } catch (e) {
      debugPrint(e.toString());
      debugPrintStack();
      throw InkException("Unexpected Error");
    }
  }

  @override
  Future<List<InkList>> getLists() async {
    final json = (await _apiService.get("lists"))['lists'];
    try {
      final list = json.map((e) {
        e['notes'] = [];
        return InkList.fromJson(e);
      }).toList();
      return List<InkList>.from(list);
    } catch (e) {
      debugPrint(e.toString());
      debugPrintStack();
      throw InkException("Unexpected Error");
    }
  }
}

final remoteListsDatasourceProvider = Provider<ListsDatasource>(
  (ref) => RemoteListsDatasource(ref.watch(apiServiceProvider)),
);
