import 'dart:async';

import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/request/command.dart';
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
