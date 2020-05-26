/// Primary resource collection route
abstract class CollectionRoute {
  /// Returns the URI for a collection of type [type].
  Uri uri(String type);

  /// Matches the [uri] with a collection route pattern.
  /// If the match is successful, calls the [onMatch] and returns true.
  /// Otherwise returns false.
  bool match(Uri uri, void Function(String type) onMatch);
}

abstract class RelationshipRoute {
  Uri uri(String type, String id, String relationship);

  /// Matches the [uri] with a relationship route pattern.
  /// If the match is successful, calls the [onMatch] and returns true.
  /// Otherwise returns false.
  bool match(Uri uri,
      void Function(String type, String id, String relationship) onMatch);
}

abstract class RelatedRoute {
  Uri uri(String type, String id, String relationship);

  /// Matches the [uri] with a related route pattern.
  /// If the match is successful, calls the [onMatch] and returns true.
  /// Otherwise returns false.
  bool match(Uri uri,
      void Function(String type, String id, String relationship) onMatch);
}

abstract class ResourceRoute {
  Uri uri(String type, String id);

  /// Matches the [uri] with a resource route pattern.
  /// If the match is successful, calls the [onMatch] and returns true.
  /// Otherwise returns false.
  bool match(Uri uri, void Function(String type, String id) onMatch);
}
