import 'package:flutter_riverpod/flutter_riverpod.dart';

class TokenStorage {
  TokenStorage(this._token);
  final String? _token;
  String? get token => _token;
}

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => TokenStorage(
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InVzZXIxQGVtYWlsLmNvbSIsImlhdCI6MTc4MjU2NzQyMywiZXhwIjoxNzg3NzUxNDIzfQ.fgf5s9FP7L0ODwaVHf3RfhOtZubR55lr2ik7RYz_kt8",
  ),
);
