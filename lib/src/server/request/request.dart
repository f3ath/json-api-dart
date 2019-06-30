import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/src/document/document.dart';
import 'package:json_api/src/document/relationship.dart';
import 'package:json_api/src/document/resource_data.dart';
import 'package:json_api/src/server/controller.dart';
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

class FetchCollectionRequest implements Request {
  final CollectionTarget target;

  FetchCollectionRequest(this.target);

  @override
  FutureOr<Response> call(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.fetchCollection(target, query);
}

class FetchResourceRequest implements Request {
  final ResourceTarget target;

  FetchResourceRequest(this.target);

  @override
  FutureOr<Response> call(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.fetchResource(target, query);
}

class FetchRelatedRequest implements Request {
  final RelatedTarget target;

  FetchRelatedRequest(this.target);

  @override
  FutureOr<Response> call(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.fetchRelated(target, query);
}

class FetchRelationshipRequest implements Request {
  final RelationshipTarget target;

  FetchRelationshipRequest(this.target);

  @override
  FutureOr<Response> call(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.fetchRelationship(target, query);
}

class DeleteResourceRequest implements Request {
  final ResourceTarget target;

  DeleteResourceRequest(this.target);

  @override
  FutureOr<Response> call(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.deleteResource(target);
}

class UpdateResourceRequest implements Request {
  final ResourceTarget target;

  UpdateResourceRequest(this.target);

  @override
  FutureOr<Response> call(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.updateResource(target,
          Document.decodeJson(payload, ResourceData.decodeJson).data.unwrap());
}

class CreateResourceRequest implements Request {
  final CollectionTarget target;

  CreateResourceRequest(this.target);

  @override
  FutureOr<Response> call(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.createResource(target,
          Document.decodeJson(payload, ResourceData.decodeJson).data.unwrap());
}

class UpdateRelationshipRequest implements Request {
  final RelationshipTarget target;

  UpdateRelationshipRequest(this.target);

  @override
  FutureOr<Response> call(Controller controller,
      Map<String, List<String>> query, Object payload) async {
    final rel = Relationship.decodeJson(payload);
    if (rel is ToOne) {
      return controller.replaceToOne(target, rel.unwrap());
    }
    if (rel is ToMany) {
      return controller.replaceToMany(target, rel.identifiers);
    }
    return ErrorResponse.badRequest([]); //TODO: meaningful error
  }
}

class AddToManyRequest implements Request {
  final RelationshipTarget target;

  AddToManyRequest(this.target);

  @override
  FutureOr<Response> call(Controller controller,
      Map<String, List<String>> query, Object payload) async {
    final rel = Relationship.decodeJson(payload);
    if (rel is ToMany) {
      return controller.addToMany(target, rel.identifiers);
    }
    return ErrorResponse.badRequest([]); //TODO: meaningful error
  }
}

class InvalidRequest implements Request {
  final target = null;
  final Response _response;

  InvalidRequest(this._response);

  @override
  Response call(Controller controller, Map<String, List<String>> query,
          Object payload) =>
      _response;
}
