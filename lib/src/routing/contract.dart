/// Makes URIs for specific targets
abstract class UriFactory {
  /// Returns a URL for the primary resource collection of type [type]
  Uri collection(String type);

  /// Returns a URL for the related resource/collection.
  /// The [type] and [id] identify the primary resource and the [relationship]
  /// is the relationship name.
  Uri related(String type, String id, String relationship);

  /// Returns a URL for the relationship itself.
  /// The [type] and [id] identify the primary resource and the [relationship]
  /// is the relationship name.
  Uri relationship(String type, String id, String relationship);

  /// Returns a URL for the primary resource of type [type] with id [id]
  Uri resource(String type, String id);
}

abstract class CollectionUriPattern {
  /// Returns the URI for a collection of type [type].
  Uri uri(String type);

  /// Matches the [uri] with a collection URI pattern.
  /// If the match is successful, calls [onMatch].
  /// Returns true if the match was successful.
  bool match(Uri uri, Function(String type) onMatch);
}

abstract class RelationshipUriPattern {
  Uri uri(String type, String id, String relationship);

  /// Matches the [uri] with a relationship URI pattern.
  /// If the match is successful, calls [onMatch].
  /// Returns true if the match was successful.
  bool match(Uri uri, Function(String type, String id, String rel) onMatch);
}

abstract class RelatedUriPattern {
  Uri uri(String type, String id, String relationship);

  /// Matches the [uri] with a related URI pattern.
  /// If the match is successful, calls [onMatch].
  /// Returns true if the match was successful.
  bool match(Uri uri, Function(String type, String id, String rel) onMatch);
}

abstract class ResourceUriPattern {
  Uri uri(String type, String id);

  /// Matches the [uri] with a resource URI pattern.
  /// If the match is successful, calls [onMatch].
  /// Returns true if the match was successful.
  bool match(Uri uri, Function(String type, String id) onMatch);
}

/// Matches the URI with URI Design patterns.
///
/// See https://jsonapi.org/recommendations/#urls
abstract class UriPatternMatcher {
  /// Matches the [uri] with route patterns.
  /// If there is a match, calls the corresponding method of the [handler].
  /// Returns true if match was found.
  bool match(Uri uri, UriMatchHandler handler);
}

abstract class UriMatchHandler {
  void collection(String type);

  void resource(String type, String id);

  void related(String type, String id, String relationship);

  void relationship(String type, String id, String relationship);
}

abstract class Routing implements UriFactory, UriPatternMatcher {}
