import 'package:json_api/src/document/identifier.dart';

/// [IdentifierObject] is a JSON representation of the [Identifier].
/// It carries all JSON-related logic and the Meta-data.
class IdentifierObject {
  final String type;
  final String id;

  IdentifierObject(this.type, this.id);

  static IdentifierObject fromIdentifier(Identifier id) =>
      IdentifierObject(id.type, id.id);

  Identifier toIdentifier() => Identifier(type, id);

  toJson() => {'type': type, 'id': id};
}
