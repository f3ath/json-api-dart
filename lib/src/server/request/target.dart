import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/request/request.dart';
import 'package:json_api/src/server/response.dart';

/// A JSON:API request may target:
/// - a single primary resource
/// - a primary resource collection
/// - a related resource or collection
/// - a relationship itself
abstract class RequestTarget {
  Request getRequest(String httpMethod);
}

class CollectionTarget implements RequestTarget {
  final String type;

  const CollectionTarget(this.type);

  @override
  Request getRequest(String httpMethod) {
    httpMethod = httpMethod.toUpperCase();
    if (httpMethod == 'GET') return FetchCollectionRequest(this);
    if (httpMethod == 'POST') return CreateResourceRequest(this);
    return InvalidRequest(ErrorResponse.methodNotAllowed([]));
  }
}

class ResourceTarget implements RequestTarget {
  final String type;
  final String id;

  const ResourceTarget(this.type, this.id);

  @override
  Request getRequest(String httpMethod) {
    httpMethod = httpMethod.toUpperCase();
    if (httpMethod == 'GET') return FetchResourceRequest(this);
    if (httpMethod == 'DELETE') return DeleteResourceRequest(this);
    if (httpMethod == 'PATCH') return UpdateResourceRequest(this);
    return InvalidRequest(ErrorResponse.methodNotAllowed([]));
  }
}

class RelationshipTarget implements RequestTarget {
  final String type;
  final String id;
  final String relationship;

  const RelationshipTarget(this.type, this.id, this.relationship);

  @override
  Request getRequest(String httpMethod) {
    httpMethod = httpMethod.toUpperCase();
    if (httpMethod == 'GET') return FetchRelationshipRequest(this);
    if (httpMethod == 'PATCH') return UpdateRelationshipRequest(this);
    if (httpMethod == 'POST') return AddToManyRequest(this);
    return InvalidRequest(ErrorResponse.methodNotAllowed([]));
  }
}

class RelatedTarget implements RequestTarget {
  final String type;
  final String id;
  final String relationship;

  const RelatedTarget(this.type, this.id, this.relationship);

  @override
  Request getRequest(String httpMethod) {
    httpMethod = httpMethod.toUpperCase();
    if (httpMethod == 'GET') return FetchRelatedRequest(this);
    return InvalidRequest(ErrorResponse.methodNotAllowed([]));
  }
}

class InvalidTarget implements RequestTarget {
  const InvalidTarget();

  @override
  Request getRequest(String httpMethod) {
    return InvalidRequest(ErrorResponse.badRequest([]));
  }
}
