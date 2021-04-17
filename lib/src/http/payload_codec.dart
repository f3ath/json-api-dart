import 'dart:convert';

/// Encodes/decodes JSON payload
class PayloadCodec {
  const PayloadCodec();

  Future<Map> decode(String body) async {
    final json = jsonDecode(body);
    if (json is Map) return json;
    throw FormatException('Invalid JSON payload: ${json.runtimeType}');
  }

  Future<String> encode(Object document) async => jsonEncode(document);
}
