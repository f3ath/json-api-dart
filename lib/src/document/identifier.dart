import 'package:json_api/src/document/identity.dart';

/// A Resource Identifier object
class Identifier with Identity {
  Identifier(this.type, this.id);

  @override
  final String type;

  @override
  final String id;

  final meta = <String, Object /*?*/ >{};

  Map<String, Object> toJson() =>
      {'type': type, 'id': id, if (meta.isNotEmpty) 'meta': meta};
}
