import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:ink/core/exceptions/ink_exception.dart';
import 'package:ink/core/services/token_storage.dart';

class ApiService {
  ApiService(this._tokenStorage);
  final TokenStorage _tokenStorage;
  final _baseUrl = "http://localhost:3000/";
  String? get _token => _tokenStorage.token;

  Future<dynamic> get(String path) async {
    late final http.Response response;
    try {
      response = await http.get(
        Uri.parse(_baseUrl + path),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
      );
      debugPrint("GET: $path\n ${response.body}\n===================");
    } catch (e) {
      throw InkException("Failed to reach the server");
    }
    late final Map<String, dynamic> responseBody;
    try {
      responseBody = jsonDecode(response.body);
    } catch (e) {
      throw InkException("Invalid Response from the server");
    }
    if (response.statusCode == 200) {
      return responseBody;
    } else {
      throw InkException(responseBody['message']);
    }
  }

  Future<dynamic> post(String path, dynamic body) async {
    late final http.Response response;
    try {
      response = await http.post(
        Uri.parse(_baseUrl + path),
        body: jsonEncode(body),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
      );
      debugPrint("POST: $path\n ${response.body}\n===================");
    } catch (e) {
      throw InkException("Failed to reach the server");
    }
    late final Map<String, dynamic> responseBody;
    try {
      responseBody = jsonDecode(response.body);
    } catch (e) {
      throw InkException("Invalid Response from the server");
    }
    if (response.statusCode.toString().startsWith("2")) {
      return responseBody;
    } else {
      throw InkException(responseBody['message']);
    }
  }

  Future<dynamic> patch(String path, dynamic body) async {
    late final http.Response response;
    try {
      response = await http.patch(
        Uri.parse(_baseUrl + path),
        body: jsonEncode(body),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
      );
      debugPrint("PATCH: $path\n ${response.body}\n===================");
    } catch (e) {
      throw InkException("Failed to reach the server");
    }
    late final Map<String, dynamic> responseBody;
    try {
      responseBody = jsonDecode(response.body);
    } catch (e) {
      throw InkException("Invalid Response from the server");
    }
    if (response.statusCode == 200) {
      return responseBody;
    } else {
      throw InkException(responseBody['message']);
    }
  }

  Future<dynamic> delete(String path) async {
    late final http.Response response;
    try {
      response = await http.delete(
        Uri.parse(_baseUrl + path),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
      );
      debugPrint("DELETE: $path\n ${response.body}\n===================");
    } catch (e) {
      throw InkException("Failed to reach the server");
    }
    late final Map<String, dynamic> responseBody;
    try {
      responseBody = jsonDecode(response.body);
    } catch (e) {
      throw InkException("Invalid Response from the server");
    }
    if (response.statusCode == 200) {
      return responseBody;
    } else {
      throw InkException(responseBody['message']);
    }
  }
}

final apiServiceProvider = Provider<ApiService>(
  (ref) => ApiService(ref.read(tokenStorageProvider)),
);
