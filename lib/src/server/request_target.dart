import 'package:json_api/src/server/_server.dart';

/// A JSON:API request may target:
/// - a single primary resource
/// - a primary resource collection
/// - a related resource or collection
/// - a relationship itself
abstract class RequestTarget {
  String get type;

  Request getRequest(String httpMethod, RequestFactory factory);
}

class CollectionTarget implements RequestTarget {
  final String type;

  const CollectionTarget(this.type);

  @override
  Request getRequest(String httpMethod, RequestFactory factory) {
    httpMethod = httpMethod.toUpperCase();
    if (httpMethod == 'GET') return factory.makeFetchCollectionRequest(this);
    if (httpMethod == 'POST') return factory.makeCreateResourceRequest(this);
    return factory.makeInvalidRequest(this);
  }
}

class ResourceTarget implements RequestTarget {
  final String type;
  final String id;

  const ResourceTarget(this.type, this.id);

  @override
  Request getRequest(String httpMethod, RequestFactory factory) {
    httpMethod = httpMethod.toUpperCase();
    if (httpMethod == 'GET') return factory.makeFetchResourceRequest(this);
    if (httpMethod == 'DELETE') return factory.makeDeleteResourceRequest(this);
    if (httpMethod == 'PATCH') return factory.makeUpdateResourceRequest(this);
    return factory.makeInvalidRequest(this);
  }
}

class RelationshipTarget implements RequestTarget {
  final String type;
  final String id;
  final String relationship;

  const RelationshipTarget(this.type, this.id, this.relationship);

  @override
  Request getRequest(String httpMethod, RequestFactory factory) {
    httpMethod = httpMethod.toUpperCase();
    if (httpMethod == 'GET') return factory.makeFetchRelationshipRequest(this);
    if (httpMethod == 'PATCH')
      return factory.makeUpdateRelationshipRequest(this);
    if (httpMethod == 'POST') return factory.makeAddToManyRequest(this);
    return factory.makeInvalidRequest(this);
  }
}

class RelatedTarget implements RequestTarget {
  final String type;
  final String id;
  final String relationship;

  const RelatedTarget(this.type, this.id, this.relationship);

  @override
  Request getRequest(String httpMethod, RequestFactory factory) {
    httpMethod = httpMethod.toUpperCase();
    if (httpMethod == 'GET') return factory.makeFetchRelatedRequest(this);
    return factory.makeInvalidRequest(this);
  }
}

abstract class RequestFactory {
  Request makeFetchCollectionRequest(CollectionTarget target);

  Request makeCreateResourceRequest(CollectionTarget target);

  Request makeFetchResourceRequest(ResourceTarget target);

  Request makeDeleteResourceRequest(ResourceTarget target);

  Request makeUpdateResourceRequest(ResourceTarget target);

  Request makeFetchRelationshipRequest(RelationshipTarget target);

  Request makeUpdateRelationshipRequest(RelationshipTarget target);

  Request makeAddToManyRequest(RelationshipTarget target);

  Request makeFetchRelatedRequest(RelatedTarget target);

  Request makeInvalidRequest(RequestTarget target);
}
