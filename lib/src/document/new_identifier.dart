/// A new Resource Identifier object, used when creating new resources on the server.
abstract class NewIdentifier {
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
