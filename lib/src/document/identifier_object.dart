import 'package:json_api/src/document/identifier.dart';

/// [IdentifierObject] is a JSON representation of an [Identifier]
/// It carries all JSON-related logic and the Meta-data.
class IdentifierObject {
  final String type;
  final String id;

  IdentifierObject(this.type, this.id);

  static IdentifierObject parse(Object json) {
    if (json is Map) {
      return IdentifierObject(json['type'], json['id']);
    }
    throw 'Can not parse IdentifierObject from $json';
  }

  static IdentifierObject fromIdentifier(Identifier id) =>
      IdentifierObject(id.type, id.id);

  Identifier toIdentifier() => Identifier(type, id);

  toJson() => {'type': type, 'id': id};
}
