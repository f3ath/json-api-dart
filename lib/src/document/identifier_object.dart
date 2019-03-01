import 'package:json_api/src/document/identifier.dart';

class IdentifierObject {
  final String type;
  final String id;
  final Map<String, Object> meta;

  IdentifierObject(this.type, this.id, {Map<String, Object> meta})
      : meta = Map.unmodifiable(meta ?? {});

  static IdentifierObject fromIdentifier(Identifier id,
          {Map<String, Object> meta}) =>
      IdentifierObject(id.type, id.id, meta: meta);

  Identifier toIdentifier() => Identifier(type, id);

  toJson() {
    final json = <String, Object>{'type': type, 'id': id};
    if (meta.isNotEmpty) json['meta'] = meta;
    return json;
  }

  static IdentifierObject fromJson(Object json) {
    if (json is Map) {
      return IdentifierObject(json['type'], json['id'], meta: json['meta']);
    }
    throw 'Can not parse IdentifierContainer from $json';
  }
}
