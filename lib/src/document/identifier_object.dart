import 'package:json_api/src/document/document_exception.dart';
import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/json_encodable.dart';

/// [IdentifierObject] is a JSON representation of the [Identifier].
/// It carries all JSON-related logic and the Meta-data.
class IdentifierObject implements JsonEncodable {
  /// Creates an instance of [IdentifierObject].
  /// [type] and [id] can not be null.
  IdentifierObject(this.type, this.id, {Map<String, Object> meta})
      : meta = Map.unmodifiable(meta ?? const {}) {
    ArgumentError.checkNotNull(type);
    ArgumentError.checkNotNull(id);
  }

  /// Resource type
  final String type;

  /// Resource id
  final String id;

  /// Meta data. May be empty or null.
  final Map<String, Object> meta;

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

  @override
  Map<String, Object> toJson() => {
        'type': type,
        'id': id,
        if (meta.isNotEmpty) 'meta': meta,
      };
}
