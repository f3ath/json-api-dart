import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/src/document/document.dart';
import 'package:json_api/src/document/relationship.dart';
import 'package:json_api/src/document/resource_data.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/request/target.dart';
import 'package:json_api/src/server/response.dart';

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
