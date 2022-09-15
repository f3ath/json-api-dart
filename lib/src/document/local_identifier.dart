/// A local Resource Identifier object
class LocalIdentifier {
  LocalIdentifier(this.type, this.lid);

  /// Resource type.
  final String type;

  /// Resource id.
  final String lid;

  /// Identifier meta-data.
  final meta = <String, Object?>{};

  Map<String, Object> toJson() =>
      {'type': type, 'lid': lid, if (meta.isNotEmpty) 'meta': meta};
}
