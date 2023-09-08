/// A new Resource Identifier object, used when creating new resources on the server.
sealed class NewIdentifier {
  /// Resource type.
  String get type;

  /// Resource id.
  String? get id;

  /// Local Resource id.
  String? get lid;

  /// Identifier meta-data.
  Map<String, Object?> get meta;

  Map<String, Object> toJson();
}

/// A Resource Identifier object
class Identifier implements NewIdentifier {
  Identifier(this.type, this.id);

  /// Resource type.
  @override
  final String type;

  /// Resource id.
  @override
  final String id;

  @override
  final lid = null;

  /// Identifier meta-data.
  @override
  final meta = <String, Object?>{};

  @override
  Map<String, Object> toJson() =>
      {'type': type, 'id': id, if (meta.isNotEmpty) 'meta': meta};
}

class LocalIdentifier implements NewIdentifier {
  LocalIdentifier(this.type, this.lid);

  /// Resource type.
  @override
  final String type;

  /// Resource id.
  @override
  final id = null;

  /// Local Resource id.
  @override
  final String lid;

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
