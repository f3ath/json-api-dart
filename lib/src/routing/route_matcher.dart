/// Matches the URI with URI Design patterns.
///
/// See https://jsonapi.org/recommendations/#urls
abstract class RouteMatcher {
  /// Matches the [uri] with route patterns.
  /// If there is a match, calls the corresponding method of the [handler].
  /// Returns true if match was found.
  bool match(Uri uri, MatchHandler handler);
}

abstract class MatchHandler {
  void collection(String type);

  void resource(String type, String id);

  void related(String type, String id, String relationship);

  void relationship(String type, String id, String relationship);
}
