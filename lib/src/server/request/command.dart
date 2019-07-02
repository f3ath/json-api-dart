import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/src/document/document.dart';
import 'package:json_api/src/document/relationship.dart';
import 'package:json_api/src/document/resource_data.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/request/target.dart';
import 'package:json_api/src/server/response.dart';

class FetchCollectionCommand implements ControllerCommand {
  final CollectionTarget target;

  FetchCollectionCommand(this.target);

  @override
  FutureOr<Response> call(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.fetchCollection(target, query);
}

class FetchResourceCommand implements ControllerCommand {
  final ResourceTarget target;

  FetchResourceCommand(this.target);

  @override
  FutureOr<Response> call(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.fetchResource(target, query);
}

class FetchRelatedCommand implements ControllerCommand {
  final RelatedTarget target;

  FetchRelatedCommand(this.target);

  @override
  FutureOr<Response> call(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.fetchRelated(target, query);
}

class FetchRelationshipCommand implements ControllerCommand {
  final RelationshipTarget target;

  FetchRelationshipCommand(this.target);

  @override
  FutureOr<Response> call(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.fetchRelationship(target, query);
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
