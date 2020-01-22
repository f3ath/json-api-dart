import 'package:json_api/src/document/document_exception.dart';
import 'package:json_api/src/document/identifier.dart';

/// [IdentifierObject] is a JSON representation of the [Identifier].
/// It carries all JSON-related logic and the Meta-data.
class IdentifierObject {
  /// Resource type
  final String type;

  /// Resource id
  final String id;

  /// Meta data. May be empty or null.
  final Map<String, Object> meta;

  /// Creates an instance of [IdentifierObject].
  /// [type] and [id] can not be null.
  IdentifierObject(this.type, this.id, {Map<String, Object> meta})
      : meta = (meta == null) ? null : Map.unmodifiable(meta) {
    ArgumentError.checkNotNull(type);
    ArgumentError.checkNotNull(id);
  }

  static IdentifierObject fromIdentifier(Identifier identifier,
          {Map<String, Object> meta}) =>
      IdentifierObject(identifier.type, identifier.id, meta: meta);

  static IdentifierObject fromJson(Object json) {
    if (json is Map) {
      return IdentifierObject(json['type'], json['id'], meta: json['meta']);
    }
    throw DocumentException('A JSON:API identifier must be a JSON object');
  }

  Identifier unwrap() => Identifier(type, id);

  Map<String, Object> toJson() => {
        'type': type,
        'id': id,
        if (meta != null) ...{'meta': meta},
      };
}
