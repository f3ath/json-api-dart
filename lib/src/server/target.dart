import 'package:json_api/url_design.dart';

/// Creates JSON:API requests.
abstract class RequestFactory<R> {
  /// Returns an object representing a GET request to a resource URI
  R fetchResource(ResourceTarget target);

  /// Returns an object representing a DELETE request to a resource URI
  R deleteResource(ResourceTarget target);

  /// Returns an object representing a PATCH request to a resource URI
  R updateResource(ResourceTarget target);

  /// Returns an object representing a GET request to a resource collection URI
  R fetchCollection(CollectionTarget target);

  /// Returns an object representing a POST request to a resource collection URI
  R createResource(CollectionTarget target);

  /// Returns an object representing a GET request to a related resource URI
  R fetchRelated(RelatedTarget target);

  /// Returns an object representing a GET request to a relationship URI
  R fetchRelationship(RelationshipTarget target);

  /// Returns an object representing a PATCH request to a relationship URI
  R updateRelationship(RelationshipTarget target);

  /// Returns an object representing a POST request to a relationship URI
  R addToRelationship(RelationshipTarget target);

  /// Returns an object representing a DELETE request to a relationship URI
  R deleteFromRelationship(RelationshipTarget target);

  /// Returns an object representing a request with a [method] which is not
  /// allowed by the [target]. Most likely, this should lead to either
  /// `405 Method Not Allowed` or `400 Bad Request`.
  R invalid(Target target, String method);
}

/// The target of a JSON:API request URI. The URI target and the request method
/// uniquely identify the meaning of the JSON:API request.
abstract class Target {
  /// Returns the request corresponding to the request [method].
  R getRequest<R>(String method, RequestFactory<R> factory);
}

/// Request URI target which is not recognized by the URL Design.
class UnmatchedTarget implements Target {
  final Uri uri;

  @override
  const UnmatchedTarget(this.uri);

  @override
  R getRequest<R>(String method, RequestFactory<R> factory) =>
      factory.invalid(this, method);
}

/// The target of a URI referring to a single resource
class ResourceTarget implements Target {
  /// Resource type
  final String type;

  /// Resource id
  final String id;

  const ResourceTarget(this.type, this.id);

  @override
  R getRequest<R>(String method, RequestFactory<R> factory) {
    switch (method.toUpperCase()) {
      case 'GET':
        return factory.fetchResource(this);
      case 'DELETE':
        return factory.deleteResource(this);
      case 'PATCH':
        return factory.updateResource(this);
      default:
        return factory.invalid(this, method);
    }
  }
}

/// The target of a URI referring a resource collection
class CollectionTarget implements Target {
  /// Resource type
  final String type;

  const CollectionTarget(this.type);

  @override
  R getRequest<R>(String method, RequestFactory<R> factory) {
    switch (method.toUpperCase()) {
      case 'GET':
        return factory.fetchCollection(this);
      case 'POST':
        return factory.createResource(this);
      default:
        return factory.invalid(this, method);
    }
  }
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

  @override
  R getRequest<R>(String method, RequestFactory<R> factory) {
    switch (method.toUpperCase()) {
      case 'GET':
        return factory.fetchRelated(this);
      default:
        return factory.invalid(this, method);
    }
  }
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

  @override
  R getRequest<R>(String method, RequestFactory<R> factory) {
    switch (method.toUpperCase()) {
      case 'GET':
        return factory.fetchRelationship(this);
      case 'PATCH':
        return factory.updateRelationship(this);
      case 'POST':
        return factory.addToRelationship(this);
      case 'DELETE':
        return factory.deleteFromRelationship(this);
      default:
        return factory.invalid(this, method);
    }
  }
}

class TargetFactory implements MatchCase<Target> {
  const TargetFactory();

  @override
  Target unmatched(Uri uri) => UnmatchedTarget(uri);

  @override
  Target collection(String type) => CollectionTarget(type);

  @override
  Target related(String type, String id, String relationship) =>
      RelatedTarget(type, id, relationship);

  @override
  Target relationship(String type, String id, String relationship) =>
      RelationshipTarget(type, id, relationship);

  @override
  Target resource(String type, String id) => ResourceTarget(type, id);
}
