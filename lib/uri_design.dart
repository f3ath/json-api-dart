/// URI Design describes how the endpoints are organized.
abstract class UriDesign implements TargetMatcher, UriFactory {
  /// Returns the URI design recommended by the JSON:API standard.
  /// @see https://jsonapi.org/recommendations/#urls
  static UriDesign standard(Uri base) => _Standard(base);
}

/// Makes URIs for specific targets
abstract class UriFactory {
  /// Returns a URL for the primary resource collection of type [type]
  Uri collectionUri(String type);

  /// Returns a URL for the related resource/collection.
  /// The [type] and [id] identify the primary resource and the [relationship]
  /// is the relationship name.
  Uri relatedUri(String type, String id, String relationship);

  /// Returns a URL for the relationship itself.
  /// The [type] and [id] identify the primary resource and the [relationship]
  /// is the relationship name.
  Uri relationshipUri(String type, String id, String relationship);

  /// Returns a URL for the primary resource of type [type] with id [id]
  Uri resourceUri(String type, String id);
}

/// Determines if a given URI matches a specific target
abstract class TargetMatcher {
  /// Matches the target of the [uri]. If the target can be determined,
  /// the corresponding method of [onTargetMatch] will be called with the target parameters
  void matchTarget(Uri uri, OnTargetMatch onTargetMatch);
}

abstract class OnTargetMatch {
  /// Called when a URI targets a collection.
  void collection(String type);

  /// Called when a URI targets a resource.
  void resource(String type, String id);

  /// Called when a URI targets a related resource or collection.
  void related(String type, String id, String relationship);

  /// Called when a URI targets a relationship.
  void relationship(String type, String id, String relationship);
}

class _Standard implements UriDesign {
  /// Returns a URL for the primary resource collection of type [type]
  @override
  Uri collectionUri(String type) => _appendToBase([type]);

  /// Returns a URL for the related resource/collection.
  /// The [type] and [id] identify the primary resource and the [relationship]
  /// is the relationship name.
  @override
  Uri relatedUri(String type, String id, String relationship) =>
      _appendToBase([type, id, relationship]);

  /// Returns a URL for the relationship itself.
  /// The [type] and [id] identify the primary resource and the [relationship]
  /// is the relationship name.
  @override
  Uri relationshipUri(String type, String id, String relationship) =>
      _appendToBase([type, id, _relationships, relationship]);

  /// Returns a URL for the primary resource of type [type] with id [id]
  @override
  Uri resourceUri(String type, String id) => _appendToBase([type, id]);

  @override
  void matchTarget(Uri uri, OnTargetMatch match) {
    if (!uri.toString().startsWith(_base.toString())) return;
    final s = uri.pathSegments.sublist(_base.pathSegments.length);
    if (s.length == 1) {
      match.collection(s[0]);
    } else if (s.length == 2) {
      match.resource(s[0], s[1]);
    } else if (s.length == 3) {
      match.related(s[0], s[1], s[2]);
    } else if (s.length == 4 && s[2] == _relationships) {
      match.relationship(s[0], s[1], s[3]);
    }
  }

  _Standard(this._base);

  static const _relationships = 'relationships';

  /// The base to be added the the generated URIs
  final Uri _base;

  Uri _appendToBase(List<String> segments) =>
      _base.replace(pathSegments: _base.pathSegments + segments);
}
