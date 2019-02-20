import 'package:json_api/core.dart';

class IdentifierContainer {
  final Identifier identifier;
  final Map<String, Object> meta;

  IdentifierContainer(this.identifier, {Map<String, Object> meta})
      : meta = Map.unmodifiable(meta ?? {});

  String get id => identifier.id;

  String get type => identifier.type;

  toJson() {
    final json = <String, Object>{'type': type, 'id': id};
    if (meta.isNotEmpty) json['meta'] = meta;
    return json;
  }

  static IdentifierContainer fromJson(Object json) {
    if (json is Map) {
      return IdentifierContainer(Identifier(json['type'], json['id']),
          meta: json['meta']);
    }
    throw 'Can not parse IdentifierContainer from $json';
  }
}
