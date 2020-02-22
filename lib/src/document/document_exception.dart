/// Indicates a violation of JSON:API Document structure or data constraints.
class DocumentException implements Exception {
  DocumentException(this.message);

  /// Human-readable text explaining the issue.
  final String message;
}
