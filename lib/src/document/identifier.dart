import 'package:json_api/src/document/identity.dart';

class Identifier with Identity {
  Identifier(this.type, this.id, {Map<String, Object> meta = const {}})
      : meta = Map.unmodifiable(meta ?? {});

  static Identifier fromJson(dynamic json) {
    if (json is Map) {
      return Identifier(json['type'], json['id'], meta: json['meta']);
    }
    throw FormatException('A JSON:API identifier must be a JSON object');
  }

  static Identifier fromKey(String key) {
    final parts = key.split(Identity.delimiter);
    if (parts.length != 2) throw ArgumentError('Invalid key');
    return Identifier(parts.first, parts.last);
  }

  @override
  final String type;

  @override
  final String id;

  final Map<String, Object> meta;

  Map<String, Object> toJson() =>
      {'type': type, 'id': id, if (meta.isNotEmpty) 'meta': meta};
}
