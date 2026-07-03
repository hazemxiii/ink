import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:ink/core/services/token_storage.dart';

class ApiService {
  ApiService(this._tokenStorage);
  final TokenStorage _tokenStorage;
  final _baseUrl = "http://localhost:3000/";
  String? get _token => _tokenStorage.token;

  Future<dynamic> get(String path) async {
    final response = await http.get(
      Uri.parse(_baseUrl + path),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_token",
      },
    );
    late final Map<String, dynamic> responseBody;
    try {
      responseBody = jsonDecode(response.body);
    } catch (e) {
      throw Exception("Invalid Response from the server");
    }
    if (response.statusCode == 200) {
      return responseBody;
    } else {
      throw Exception(responseBody['message']);
    }
  }

  Future<dynamic> post(String path, dynamic body) async {
    final response = await http.post(
      Uri.parse(_baseUrl + path),
      body: jsonEncode(body),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_token",
      },
    );
    late final Map<String, dynamic> responseBody;
    try {
      responseBody = jsonDecode(response.body);
    } catch (e) {
      throw Exception("Invalid Response from the server");
    }
    if (response.statusCode == 200) {
      return responseBody;
    } else {
      throw Exception(responseBody['message']);
    }
  }

  Future<dynamic> patch(String path, dynamic body) async {
    final response = await http.patch(
      Uri.parse(_baseUrl + path),
      body: jsonEncode(body),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_token",
      },
    );
    late final Map<String, dynamic> responseBody;
    try {
      responseBody = jsonDecode(response.body);
    } catch (e) {
      throw Exception("Invalid Response from the server");
    }
    if (response.statusCode == 200) {
      return responseBody;
    } else {
      throw Exception(responseBody['message']);
    }
  }

  Future<dynamic> delete(String path) async {
    final response = await http.delete(
      Uri.parse(_baseUrl + path),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_token",
      },
    );
    late final Map<String, dynamic> responseBody;
    try {
      responseBody = jsonDecode(response.body);
    } catch (e) {
      throw Exception("Invalid Response from the server");
    }
    if (response.statusCode == 200) {
      return responseBody;
    } else {
      throw Exception(responseBody['message']);
    }
  }
}

final apiServiceProvider = Provider<ApiService>(
  (ref) => ApiService(ref.read(tokenStorageProvider)),
);
