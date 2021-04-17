import 'package:json_api/src/document/identity.dart';

/// A Resource Identifier object
class Identifier with Identity {
  Identifier(this.type, this.id);

  static Identifier of(Identity identity) =>
      Identifier(identity.type, identity.id);

  @override
  final String type;
  @override
  final String id;

  /// Identifier meta-data.
  final meta = <String, Object?>{};

  Map<String, Object> toJson() =>
      {'type': type, 'id': id, if (meta.isNotEmpty) 'meta': meta};
}
