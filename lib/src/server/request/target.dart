import 'dart:async';

import 'package:json_api/src/document/document.dart';
import 'package:json_api/src/document/relationship.dart';
import 'package:json_api/src/document/resource_data.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/request/query.dart';
import 'package:json_api/src/server/response.dart';

/// Performs double-dispatch on Controller methods
abstract class ControllerCommand {
  FutureOr<Response> call(
      Controller controller, Map<String, List<String>> query, Object payload);
}

/// A JSON:API request may target:
/// - a single primary resource
/// - a primary resource collection
/// - a related resource or collection
/// - a relationship itself
abstract class RequestTarget {
  ControllerCommand getCommand(String httpMethod);
}

class CollectionTarget implements RequestTarget {
  final String type;

  const CollectionTarget(this.type);

  @override
  ControllerCommand getCommand(String httpMethod) {
    httpMethod = httpMethod.toUpperCase();
    if (httpMethod == 'GET') return FetchCollectionCommand(this);
    if (httpMethod == 'POST') return CreateResourceCommand(this);
    return InvalidCommand(ErrorResponse.methodNotAllowed([]));
  }
}

class ResourceTarget implements RequestTarget {
  final String type;
  final String id;

  const ResourceTarget(this.type, this.id);

  @override
  ControllerCommand getCommand(String httpMethod) {
    httpMethod = httpMethod.toUpperCase();
    if (httpMethod == 'GET') return FetchResourceCommand(this);
    if (httpMethod == 'DELETE') return DeleteResourceCommand(this);
    if (httpMethod == 'PATCH') return UpdateResourceCommand(this);
    return InvalidCommand(ErrorResponse.methodNotAllowed([]));
  }
}

class RelationshipTarget implements RequestTarget {
  final String type;
  final String id;
  final String relationship;

  const RelationshipTarget(this.type, this.id, this.relationship);

  @override
  ControllerCommand getCommand(String httpMethod) {
    httpMethod = httpMethod.toUpperCase();
    if (httpMethod == 'GET') return FetchRelationshipCommand(this);
    if (httpMethod == 'PATCH') return UpdateRelationshipCommand(this);
    if (httpMethod == 'POST') return AddToManyCommand(this);
    return InvalidCommand(ErrorResponse.methodNotAllowed([]));
  }
}

class RelatedTarget implements RequestTarget {
  final String type;
  final String id;
  final String relationship;

  const RelatedTarget(this.type, this.id, this.relationship);

  @override
  ControllerCommand getCommand(String httpMethod) {
    httpMethod = httpMethod.toUpperCase();
    if (httpMethod == 'GET') return FetchRelatedCommand(this);
    return InvalidCommand(ErrorResponse.methodNotAllowed([]));
  }
}

class InvalidTarget implements RequestTarget {
  const InvalidTarget();

  @override
  ControllerCommand getCommand(String httpMethod) {
    return InvalidCommand(ErrorResponse.badRequest([]));
  }
}

class FetchCollectionCommand implements ControllerCommand {
  final CollectionTarget target;

  FetchCollectionCommand(this.target);

  @override
  FutureOr<Response> call(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.fetchCollection(target, Query(query));
}

class FetchResourceCommand implements ControllerCommand {
  final ResourceTarget target;

  FetchResourceCommand(this.target);

  @override
  FutureOr<Response> call(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.fetchResource(target, Query(query));
}

class FetchRelatedCommand implements ControllerCommand {
  final RelatedTarget target;

  FetchRelatedCommand(this.target);

  @override
  FutureOr<Response> call(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.fetchRelated(target, Query(query));
}

class FetchRelationshipCommand implements ControllerCommand {
  final RelationshipTarget target;

  FetchRelationshipCommand(this.target);

  @override
  FutureOr<Response> call(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.fetchRelationship(target, Query(query));
}

class DeleteResourceCommand implements ControllerCommand {
  final ResourceTarget target;

  DeleteResourceCommand(this.target);

  @override
  FutureOr<Response> call(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.deleteResource(target);
}

class UpdateResourceCommand implements ControllerCommand {
  final ResourceTarget target;

  UpdateResourceCommand(this.target);

  @override
  FutureOr<Response> call(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.updateResource(target,
          Document.decodeJson(payload, ResourceData.decodeJson).data.unwrap());
}

class CreateResourceCommand implements ControllerCommand {
  final CollectionTarget target;

  CreateResourceCommand(this.target);

  @override
  FutureOr<Response> call(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.createResource(target,
          Document.decodeJson(payload, ResourceData.decodeJson).data.unwrap());
}

class UpdateRelationshipCommand implements ControllerCommand {
  final RelationshipTarget target;

  UpdateRelationshipCommand(this.target);

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

class AddToManyCommand implements ControllerCommand {
  final RelationshipTarget target;

  AddToManyCommand(this.target);

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

class InvalidCommand implements ControllerCommand {
  final target = null;
  final Response _response;

  InvalidCommand(this._response);

  @override
  Response call(Controller controller, Map<String, List<String>> query,
          Object payload) =>
      _response;
}
