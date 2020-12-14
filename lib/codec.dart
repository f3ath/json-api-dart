library codec;

import 'dart:convert';

abstract class PayloadCodec {
  Future<Map> decode(String body);

  Future<String> encode(Object document);
}

class DefaultCodec implements PayloadCodec {
  const DefaultCodec();

  @override
  Future<Map> decode(String body) async {
    final json = jsonDecode(body);
    if (json is Map) return json;
    throw FormatException('Invalid JSON payload: ${json.runtimeType}');
  }

  @override
  Future<String> encode(Object document) async => jsonEncode(document);
}
