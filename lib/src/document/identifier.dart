import 'package:json_api/document.dart';

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
