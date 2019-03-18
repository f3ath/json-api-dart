import 'package:json_api/src/document/identifier.dart';

/// [IdentifierJson] is a JSON representation of the [Identifier].
/// It carries all JSON-related logic and the Meta-data.
class IdentifierJson {
  final String type;
  final String id;

  IdentifierJson(this.type, this.id);

  static IdentifierJson fromIdentifier(Identifier id) =>
      IdentifierJson(id.type, id.id);

  Identifier toIdentifier() => Identifier(type, id);

  toJson() => {'type': type, 'id': id};
}
