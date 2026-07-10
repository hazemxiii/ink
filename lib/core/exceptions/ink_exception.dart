class InkException implements Exception {
  InkException(dynamic msg) {
    if (msg is String) {
      message = msg;
    } else if (msg is List) {
      message = msg.join(", ");
    }
  }
  late final String message;

  @override
  String toString() {
    return message;
  }
}
