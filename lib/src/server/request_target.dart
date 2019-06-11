import 'package:json_api/src/server/_server.dart';

/// A JSON:API request may target:
/// - a single primary resource
/// - a primary resource collection
/// - a related resource or collection
/// - a relationship itself
abstract class RequestTarget implements ControllerDispatcherProvider {
  String get type;
}

abstract class ControllerDispatcherProvider {
  ControllerDispatcher getDispatcher(
      String method, ControllerDispatcherFactory factory);
}

class CollectionTarget implements RequestTarget {
  final String type;

  const CollectionTarget(this.type);

  @override
  ControllerDispatcher getDispatcher(
      String method, ControllerDispatcherFactory factory) {
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
  ControllerDispatcher getDispatcher(
      String method, ControllerDispatcherFactory factory) {
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
  ControllerDispatcher getDispatcher(
      String method, ControllerDispatcherFactory factory) {
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
  ControllerDispatcher getDispatcher(
      String method, ControllerDispatcherFactory factory) {
    method = method.toUpperCase();
    if (method == 'GET') return factory.makeFetchRelatedRequest(this);
    return factory.makeInvalidRequest(this);
  }
}

abstract class ControllerDispatcherFactory {
  ControllerDispatcher makeFetchCollectionRequest(CollectionTarget target);

  ControllerDispatcher makeCreateResourceRequest(CollectionTarget target);

  ControllerDispatcher makeFetchResourceRequest(ResourceTarget target);

  ControllerDispatcher makeDeleteResourceRequest(ResourceTarget target);

  ControllerDispatcher makeUpdateResourceRequest(ResourceTarget target);

  ControllerDispatcher makeFetchRelationshipRequest(RelationshipTarget target);

  ControllerDispatcher makeUpdateRelationshipRequest(RelationshipTarget target);

  ControllerDispatcher makeAddToManyRequest(RelationshipTarget target);

  ControllerDispatcher makeFetchRelatedRequest(RelatedTarget target);

  ControllerDispatcher makeInvalidRequest(RequestTarget target);
}
