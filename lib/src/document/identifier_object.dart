import 'package:json_api/src/document/decoding_exception.dart';
import 'package:json_api/src/document/identifier.dart';

/// [IdentifierObject] is a JSON representation of the [Identifier].
/// It carries all JSON-related logic and the Meta-data.
class IdentifierObject {
  final String type;
  final String id;

  final Map<String, Object> meta;

  IdentifierObject(this.type, this.id, {this.meta});

  /// Returns null if [identifier] is null
  static IdentifierObject fromIdentifier(Identifier identifier,
          {Map<String, Object> meta}) =>
      identifier == null
          ? null
          : IdentifierObject(identifier.type, identifier.id, meta: meta);

  static IdentifierObject fromJson(Object json) {
    if (json is Map) {
      return IdentifierObject(json['type'], json['id'], meta: json['meta']);
    }
    throw DecodingException('Can not decode IdentifierObject from $json');
  }

  Identifier unwrap() => Identifier(type, id);

  Map<String, Object> toJson() => {
        'type': type,
        'id': id,
        if (meta != null) ...{'meta': meta},
      };
}
