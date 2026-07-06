class InkException implements Exception {
  InkException(this.message);
  final String message;

  @override
  String toString() {
    return message;
  }
}
