import 'dart:async';
import 'dart:convert';

/// Encodes/decodes JSON payload.
class PayloadCodec {
  const PayloadCodec();

  /// Decodes a JSON string into a Map
  FutureOr<Map> decode(String json) {
    final decoded = jsonDecode(json);
    if (decoded is Map) return decoded;
    throw FormatException('Invalid JSON payload: ${decoded.runtimeType}');
  }

  /// Encodes a JSON:API document into a JSON string.
  FutureOr<String> encode(Object document) => jsonEncode(document);
}
