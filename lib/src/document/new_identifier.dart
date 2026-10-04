import 'package:json_api/src/document/json_encodable.dart';

/// A new Resource Identifier object, used when creating new resources on the server.
sealed class NewIdentifier implements JsonEncodable {
  /// Resource type.
  String get type;

  /// Resource id.
  String? get id;

  /// Local Resource id.
  String? get lid;

  /// Identifier meta-data.
  Map<String, Object?> get meta;

  @override
  Map<String, Object> toJson();
}

/// A Resource Identifier object
class Identifier(
  /// Resource type.
  @override final String type,

  /// Resource id.
  @override final String id,
) implements NewIdentifier {
  @override
  final lid = null;

  /// Identifier meta-data.
  @override
  final meta = <String, Object?>{};

  @override
  Map<String, Object> toJson() => {
    'type': type,
    'id': id,
    if (meta.isNotEmpty) 'meta': meta,
  };
}

class LocalIdentifier(
  /// Resource type.
  @override final String type,

  /// Local Resource id.
  @override final String lid,
) implements NewIdentifier {
  /// Resource id.
  @override
  final id = null;

  /// Identifier meta-data.
  @override
  final meta = <String, Object?>{};

  @override
  Map<String, Object> toJson() => {
    'type': type,
    'lid': lid,
    if (meta.isNotEmpty) 'meta': meta,
  };

  Identifier toIdentifier(String id) => Identifier(type, id)..meta.addAll(meta);
}
