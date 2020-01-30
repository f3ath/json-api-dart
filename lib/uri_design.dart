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
  /// Returns the target of the [uri] or null.
  Target matchTarget(Uri uri);
}

abstract class Target {}

/// The target of a URI referring a resource collection
class CollectionTarget implements Target {
  /// Resource type
  final String type;

  const CollectionTarget(this.type);
}

/// The target of a URI referring to a single resource
class ResourceTarget implements Target {
  /// Resource type
  final String type;

  /// Resource id
  final String id;

  const ResourceTarget(this.type, this.id);
}

/// The target of a URI referring a related resource or collection
class RelatedTarget implements Target {
  /// Resource type
  final String type;

  /// Resource id
  final String id;

  /// Relationship name
  final String relationship;

  const RelatedTarget(this.type, this.id, this.relationship);
}

/// The target of a URI referring a relationship
class RelationshipTarget implements Target {
  /// Resource type
  final String type;

  /// Resource id
  final String id;

  /// Relationship name
  final String relationship;

  const RelationshipTarget(this.type, this.id, this.relationship);
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
  Target matchTarget(Uri uri) {
    if (!uri.toString().startsWith(_base.toString())) return null;
    final s = uri.pathSegments.sublist(_base.pathSegments.length);
    if (s.length == 1) {
      return CollectionTarget(s[0]);
    } else if (s.length == 2) {
      return ResourceTarget(s[0], s[1]);
    } else if (s.length == 3) {
      return RelatedTarget(s[0], s[1], s[2]);
    } else if (s.length == 4 && s[2] == _relationships) {
      return RelationshipTarget(s[0], s[1], s[3]);
    }
    return null;
  }

  const _Standard(this._base);

  static const _relationships = 'relationships';

  /// The base to be added the the generated URIs
  final Uri _base;

  Uri _appendToBase(List<String> segments) =>
      _base.replace(pathSegments: _base.pathSegments + segments);
}
