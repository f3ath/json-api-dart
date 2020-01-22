/// Indicates a violation of JSON:API Document structure or data.
class DocumentException implements Exception {
  /// Human-readable text explaining the issue..
  final String message;

  @override
  String toString() => message;

  DocumentException(this.message);

  /// Throws a [DocumentException] with the [message] if [value] is null.
  static void throwIfNull(Object value, String message) {
    if (value == null) throw DocumentException(message);
  }
}
