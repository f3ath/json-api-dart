/// A JSON:API request may target:
/// - a single primary resource
/// - a primary resource collection
/// - a related resource or collection
/// - a relationship itself
abstract class RequestTarget {
  String get type;

  /// Returns the request for the given [method]
  R getRequest<R>(String method, RequestFactory<R> factory);
}

class CollectionTarget implements RequestTarget {
  final String type;

  const CollectionTarget(this.type);

  @override
  R getRequest<R>(String method, RequestFactory<R> factory) {
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
  R getRequest<R>(String method, RequestFactory<R> factory) {
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
  R getRequest<R>(String method, RequestFactory<R> factory) {
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
  R getRequest<R>(String method, RequestFactory<R> factory) {
    method = method.toUpperCase();
    if (method == 'GET') return factory.makeFetchRelatedRequest(this);
    return factory.makeInvalidRequest(this);
  }
}

abstract class RequestFactory<R> {
  R makeFetchCollectionRequest(CollectionTarget target);

  R makeCreateResourceRequest(CollectionTarget target);

  R makeFetchResourceRequest(ResourceTarget target);

  R makeDeleteResourceRequest(ResourceTarget target);

  R makeUpdateResourceRequest(ResourceTarget target);

  R makeFetchRelationshipRequest(RelationshipTarget target);

  R makeUpdateRelationshipRequest(RelationshipTarget target);

  R makeAddToManyRequest(RelationshipTarget target);

  R makeFetchRelatedRequest(RelatedTarget target);

  R makeInvalidRequest(RequestTarget target);
}
