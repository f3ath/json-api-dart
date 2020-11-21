import 'package:json_api/src/document/identity.dart';

/// A Resource Identifier object
class Identifier with Identity {
  Identifier(this.type, this.id);

  /// Created a new [Identifier] from an [Identity] key.
  static Identifier fromKey(String key) {
    final p = Identity.split(key);
    return Identifier(p.first, p.last);
  }

  @override
  final String type;

  @override
  final String id;

  /// Identifier meta-data.
  final meta = <String, Object /*?*/ >{};

  Map<String, Object> toJson() =>
      {'type': type, 'id': id, if (meta.isNotEmpty) 'meta': meta};
}
