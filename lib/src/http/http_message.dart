import 'dart:collection';

class HttpMessage {
  HttpMessage(this.body);

  /// Message body
  final String body;

  /// Message headers. Case-insensitive.
  final headers = LinkedHashMap<String, String>(
      equals: (a, b) => a.toLowerCase() == b.toLowerCase(),
      hashCode: (s) => s.toLowerCase().hashCode);
}
