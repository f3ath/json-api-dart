/// Matches the URI with URI Design patterns.
///
/// See https://jsonapi.org/recommendations/#urls
abstract class RouteMatcher {
  /// Matches the [uri] with a collection route pattern.
  /// If the match is successful, calls the [onMatch] and returns true.
  /// Otherwise returns false.
  bool matchCollection(Uri uri, void Function(String type) onMatch);

  /// Matches the [uri] with a resource route pattern.
  /// If the match is successful, calls the [onMatch] and returns true.
  /// Otherwise returns false.
  bool matchResource(Uri uri, void Function(String type, String id) onMatch);

  /// Matches the [uri] with a related route pattern.
  /// If the match is successful, calls the [onMatch] and returns true.
  /// Otherwise returns false.
  bool matchRelated(Uri uri,
      void Function(String type, String id, String relationship) onMatch);

  /// Matches the [uri] with a relationship route pattern.
  /// If the match is successful, calls the [onMatch] and returns true.
  /// Otherwise returns false.
  bool matchRelationship(Uri uri,
      void Function(String type, String id, String relationship) onMatch);
}
