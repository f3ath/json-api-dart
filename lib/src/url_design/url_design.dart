/// URL Design describes how the endpoints are organized.
abstract class UrlDesign implements TargetMatcher, UrlFactory {}

/// Makes URIs for specific targets
abstract class UrlFactory {
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

/// Determines if a given URI matches a specific target
abstract class TargetMatcher {
  /// Matches the target of the [uri]. If the target can be determined,
  /// the corresponding method of [matchCase] will be called with the target parameters
  /// and the result will be returned.
  /// Otherwise returns the result of [MatchCase.unmatched].
  T match<T>(Uri uri, MatchCase<T> matchCase);
}

abstract class MatchCase<T> {
  T collection(String type);

  T resource(String type, String id);

  T relationship(String type, String id, String relationship);

  T related(String type, String id, String relationship);

  T unmatched();
}
