import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/services/api_service.dart';
import 'package:ink/core/services/prefs.dart';

class SyncQueueService {
  SyncQueueService({required this._prefs});

  final Prefs _prefs;
  final List<SyncRequest> _queue = [];
  bool _isReady = false;

  Future<void> init() async {
    _queue.addAll(await _prefs.getSyncQueue());
    _isReady = true;
    _prefs.setSyncQueue(_queue);
  }

  void add(SyncRequest request) {
    _queue.add(request);
    if (_isReady) {
      _prefs.setSyncQueue(_queue);
    }
    printQueue();
  }

  void printQueue() {
    debugPrint(
      '===================SyncQueueService: ${_queue.length} requests in queue===================',
    );
    for (var request in _queue) {
      debugPrint(
        '  - ${request.resource} ${request.method} ${request.bodyJson}',
      );
    }
    debugPrint(
      '+++++++++++++++++++++++++++++++++++++SyncQueueService+++++++++++++++++++++++++++++++++++++',
    );
  }

  List<SyncRequest> get queue => _queue;
}

class SyncRequest {
  SyncRequest({required this.resource, required this.method, this.bodyJson});

  SyncRequest.fromJson(Map<String, dynamic> json)
    : resource = json['resource'],
      method = Methods.values.firstWhere((m) => m.name == json['method']),
      bodyJson = json['body'];

  Map<String, dynamic> toJson() {
    return {'resource': resource, 'method': method.name, 'body': bodyJson};
  }

  final String resource;
  final String? bodyJson;
  final Methods method;
}

final syncQueueServiceProvider = Provider<SyncQueueService>((ref) {
  return SyncQueueService(prefs: ref.read(prefsProvider));
});
