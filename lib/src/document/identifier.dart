import 'package:json_api/core.dart';

/// A Resource Identifier object
class Identifier {
  Identifier(this.ref);

  final Ref ref;

  /// Identifier meta-data.
  final meta = <String, Object?>{};

  Map<String, Object> toJson() =>
      {'type': ref.type, 'id': ref.id, if (meta.isNotEmpty) 'meta': meta};
}
