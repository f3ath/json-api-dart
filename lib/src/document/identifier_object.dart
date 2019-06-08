import 'package:json_api/src/document/decoding_exception.dart';
import 'package:json_api/src/document/identifier.dart';

/// [IdentifierObject] is a JSON representation of the [Identifier].
/// It carries all JSON-related logic and the Meta-data.
class IdentifierObject {
  final String type;
  final String id;
  final Map<String, String> meta;

  IdentifierObject(this.type, this.id, {Map<String, Object> meta})
      : meta = meta == null ? null : Map.from(meta);

  static IdentifierObject fromIdentifier(Identifier id) =>
      IdentifierObject(id.type, id.id);

  static IdentifierObject decodeJson(Object json) {
    if (json is Map) {
      return IdentifierObject(json['type'], json['id'], meta: json['meta']);
    }
    throw DecodingException('Can not decode IdentifierObject from $json');
  }

  Identifier toIdentifier() => Identifier(type, id);

  Map<String, Object> toJson() {
    final json = <String, Object>{'type': type, 'id': id};
    if (meta != null) json['meta'] = meta;
    return json;
  }
}
