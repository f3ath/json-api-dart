import 'package:json_api/resource.dart';

class IdentifierEnvelope {
  final String type;
  final String id;
  final Map<String, Object> meta;

  IdentifierEnvelope(this.type, this.id, {Map<String, Object> meta})
      : meta = Map.unmodifiable(meta ?? {});

  static IdentifierEnvelope fromIdentifier(Identifier id,
          {Map<String, Object> meta}) =>
      IdentifierEnvelope(id.type, id.id, meta: meta);

  Identifier toIdentifier() => Identifier(type, id);

  toJson() {
    final json = <String, Object>{'type': type, 'id': id};
    if (meta.isNotEmpty) json['meta'] = meta;
    return json;
  }

  static IdentifierEnvelope fromJson(Object json) {
    if (json is Map) {
      return IdentifierEnvelope(json['type'], json['id'], meta: json['meta']);
    }
    throw 'Can not parse IdentifierContainer from $json';
  }
}
