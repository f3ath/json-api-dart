import 'package:json_api/src/server/_server.dart';

/// A JSON:API request may target:
/// - a single primary resource
/// - a primary resource collection
/// - a related resource or collection
/// - a relationship itself
abstract class RequestTarget {
  String get type;

  /// Returns the request for the given [method]
  CanCallController getRequest(String method, RequestFactory factory);
}

class CollectionTarget implements RequestTarget {
  final String type;

  const CollectionTarget(this.type);

  @override
  CanCallController getRequest(String method, RequestFactory factory) {
    method = method.toUpperCase();
    if (method == 'GET') return factory.makeFetchCollectionRequest(this);
    if (method == 'POST') return factory.makeCreateResourceRequest(this);
    return factory.makeInvalidRequest(this);
  }
}

class ResourceTarget implements RequestTarget {
  final String type;
  final String id;

  const ResourceTarget(this.type, this.id);

  @override
  CanCallController getRequest(String method, RequestFactory factory) {
    method = method.toUpperCase();
    if (method == 'GET') return factory.makeFetchResourceRequest(this);
    if (method == 'DELETE') return factory.makeDeleteResourceRequest(this);
    if (method == 'PATCH') return factory.makeUpdateResourceRequest(this);
    return factory.makeInvalidRequest(this);
  }
}

class RelationshipTarget implements RequestTarget {
  final String type;
  final String id;
  final String relationship;

  const RelationshipTarget(this.type, this.id, this.relationship);

  @override
  CanCallController getRequest(String method, RequestFactory factory) {
    method = method.toUpperCase();
    if (method == 'GET') return factory.makeFetchRelationshipRequest(this);
    if (method == 'PATCH') return factory.makeUpdateRelationshipRequest(this);
    if (method == 'POST') return factory.makeAddToManyRequest(this);
    return factory.makeInvalidRequest(this);
  }
}

class RelatedTarget implements RequestTarget {
  final String type;
  final String id;
  final String relationship;

  const RelatedTarget(this.type, this.id, this.relationship);

  @override
  CanCallController getRequest(String method, RequestFactory factory) {
    method = method.toUpperCase();
    if (method == 'GET') return factory.makeFetchRelatedRequest(this);
    return factory.makeInvalidRequest(this);
  }
}

abstract class RequestFactory {
  CanCallController makeFetchCollectionRequest(CollectionTarget target);

  CanCallController makeCreateResourceRequest(CollectionTarget target);

  CanCallController makeFetchResourceRequest(ResourceTarget target);

  CanCallController makeDeleteResourceRequest(ResourceTarget target);

  CanCallController makeUpdateResourceRequest(ResourceTarget target);

  CanCallController makeFetchRelationshipRequest(RelationshipTarget target);

  CanCallController makeUpdateRelationshipRequest(RelationshipTarget target);

  CanCallController makeAddToManyRequest(RelationshipTarget target);

  CanCallController makeFetchRelatedRequest(RelatedTarget target);

  CanCallController makeInvalidRequest(RequestTarget target);
}
