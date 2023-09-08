/// A collection is not found on the server.
class CollectionNotFound implements Exception {
  CollectionNotFound(this.type);

  /// Collection type.
  final String type;
}
