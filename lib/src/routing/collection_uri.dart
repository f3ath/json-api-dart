/// Resource collection URL
abstract class CollectionUri {
  /// Returns a URL for a collection of type [type]
  Uri uri(String type);

  /// Returns true is the [uri] is a collection.
  /// If matches, the [onMatch] will be called with the collection type.
  bool match(Uri uri, void Function(String type) onMatch);
}
