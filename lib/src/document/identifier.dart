import 'package:json_api/src/document/document_exception.dart';
import 'package:json_api/src/document/identity.dart';
import 'package:json_api/src/document/meta.dart';

/// Resource identifier
///
/// Together with [Resource] forms the core of the Document model.
/// Identifiers are passed between the server and the client in the form
/// of [IdentifierObject]s.
class Identifier with Meta, Identity {
  /// Neither [type] nor [id] can be null or empty.
  Identifier(this.type, this.id, {Map<String, Object> meta}) {
    ArgumentError.checkNotNull(type);
    ArgumentError.checkNotNull(id);
    this.meta.addAll(meta ?? {});
  }

  static Identifier fromJson(Object json) {
    if (json is Map) {
      return Identifier(json['type'], json['id'], meta: json['meta']);
    }
    throw DocumentException('A JSON:API identifier must be a JSON object');
  }

  /// Resource type
  @override
  final String type;

  /// Resource id
  @override
  final String id;

  Map<String, Object> toJson() => {
        'type': type,
        'id': id,
        if (meta.isNotEmpty) 'meta': meta,
      };
}
