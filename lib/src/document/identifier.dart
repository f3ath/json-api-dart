import 'package:json_api/src/document/resource.dart';

/// A Resource Identifier object
class Identifier {
  Identifier(this.type, this.id);

  static Identifier of(Resource resource) =>
      Identifier(resource.type, resource.id);

  final String type;
  final String id;

  /// Identifier meta-data.
  final meta = <String, Object?>{};

  Map<String, Object> toJson() =>
      {'type': type, 'id': id, if (meta.isNotEmpty) 'meta': meta};
}
