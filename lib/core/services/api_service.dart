import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:ink/core/exceptions/ink_exception.dart';
import 'package:ink/core/exceptions/internet_ink_exception.dart';
import 'package:ink/core/services/logger.dart';
import 'package:ink/core/services/token_storage.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

enum Methods { get, post, patch, delete }

class ApiService {
  ApiService(this._tokenStorage);
  final TokenStorage _tokenStorage;
  final _baseUrl = "http://localhost:3000/";
  String? get _token => _tokenStorage.token;

  Future<bool> _hasInternet() async {
    return await InternetConnection().hasInternetAccess;
  }

  Future<dynamic> get(String path) async {
    if (!(await _hasInternet())) {
      throw InternetInkException("No internet connection");
    }
    late final http.Response response;
    try {
      response = await http.get(
        Uri.parse(_baseUrl + path),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
      );
      Logger.log("GET: $path\n ${response.body}");
    } catch (e) {
      throw InternetInkException("Failed to reach the server");
    }
    late final Map<String, dynamic> responseBody;
    try {
      responseBody = jsonDecode(response.body);
    } catch (e) {
      throw InkException("Invalid Response from the server");
    }
    if (response.statusCode == 200) {
      return responseBody;
    } else if (response.statusCode == 500) {
      throw InternetInkException("Server error");
    } else {
      throw InkException(responseBody['message']);
    }
  }

  Future<dynamic> post(
    String path,
    dynamic body, {
    bool encodeBody = true,
    String? isoDate,
  }) async {
    if (!(await _hasInternet())) {
      throw InternetInkException("No internet connection");
    }
    late final http.Response response;
    try {
      response = await http.post(
        Uri.parse(_baseUrl + path),
        body: encodeBody ? jsonEncode(body) : body,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
          "timestamp": ?isoDate,
        },
      );
      Logger.log("POST: $path\n ${response.body}");
    } catch (e) {
      throw InternetInkException("Failed to reach the server");
    }
    late final Map<String, dynamic> responseBody;
    try {
      responseBody = jsonDecode(response.body);
    } catch (e) {
      throw InkException("Invalid Response from the server");
    }
    if (response.statusCode.toString().startsWith("2")) {
      return responseBody;
    } else if (response.statusCode == 500) {
      throw InternetInkException("Server error");
    } else {
      throw InkException(responseBody['message']);
    }
  }

  Future<dynamic> patch(
    String path,
    dynamic body, {
    bool encodeBody = true,
    String? isoDate,
  }) async {
    if (!(await _hasInternet())) {
      throw InternetInkException("No internet connection");
    }
    late final http.Response response;
    try {
      response = await http.patch(
        Uri.parse(_baseUrl + path),
        body: encodeBody ? jsonEncode(body) : body,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
          "timestamp": ?isoDate,
        },
      );
      Logger.log("PATCH: $path\n ${response.body}");
    } catch (e) {
      throw InternetInkException("Failed to reach the server");
    }
    late final Map<String, dynamic> responseBody;
    try {
      responseBody = jsonDecode(response.body);
    } catch (e) {
      throw InkException("Invalid Response from the server");
    }
    if (response.statusCode == 200) {
      return responseBody;
    } else if (response.statusCode == 500) {
      throw InternetInkException("Server error");
    } else {
      throw InkException(responseBody['message']);
    }
  }

  Future<dynamic> delete(String path, {String? isoDate}) async {
    if (!(await _hasInternet())) {
      throw InternetInkException("No internet connection");
    }
    late final http.Response response;
    try {
      response = await http.delete(
        Uri.parse(_baseUrl + path),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
          "timestamp": ?isoDate,
        },
      );
      Logger.log("DELETE: $path\n ${response.body}");
    } catch (e) {
      throw InternetInkException("Failed to reach the server");
    }
    late final Map<String, dynamic> responseBody;
    try {
      responseBody = jsonDecode(response.body);
    } catch (e) {
      throw InkException("Invalid Response from the server");
    }
    if (response.statusCode == 200) {
      return responseBody;
    } else if (response.statusCode == 500) {
      throw InternetInkException("Server error");
    } else {
      throw InkException(responseBody['message']);
    }
  }
}

final apiServiceProvider = Provider<ApiService>(
  (ref) => ApiService(ref.read(tokenStorageProvider)),
);
