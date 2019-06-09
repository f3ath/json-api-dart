import 'dart:async';

import 'package:json_api/src/document/document.dart';
import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/json_api_error.dart';
import 'package:json_api/src/document/relationship.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/document/resource_data.dart';
import 'package:json_api/src/server/collection.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/page.dart';
import 'package:json_api/src/server/request_target.dart';
import 'package:json_api/src/server/response.dart';

abstract class Request {
  Response _response = ErrorResponse.notImplemented([]);

  RequestTarget get target;

  Response get response => _response;

  FutureOr<void> call(
      Controller controller, Map<String, List<String>> query, Object payload);

  void errorNotFound(List<JsonApiError> errors) {
    _response = ErrorResponse.notFound(errors);
  }

  void errorConflict(List<JsonApiError> errors) {
    _response = ErrorResponse.conflict(errors);
  }

  void error(int status, List<JsonApiError> errors) {
    _response = ErrorResponse(status, errors);
  }
}

class FetchCollection extends Request {
  final CollectionTarget target;

  FetchCollection(this.target);

  @override
  FutureOr<void> call(Controller controller, Map<String, List<String>> query,
          Object payload) =>
      controller.fetchCollection(this, query);

  void sendCollection(Collection<Resource> resources,
      {Iterable<Resource> included = const [], Page page}) {
    _response = CollectionResponse(resources, included: included, page: page);
  }
}

class FetchResource extends Request {
  final ResourceTarget target;

  FetchResource(this.target);

  @override
  FutureOr<Response> call(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.fetchResource(this, query);

  void sendResource(Resource resource, {Iterable<Resource> included}) {
    _response = ResourceResponse(resource, included: included);
  }

  void sendSeeOther(Resource resource) {
    _response = SeeOther(resource);
  }
}

class FetchRelated extends Request {
  final RelatedTarget target;

  FetchRelated(this.target);

  @override
  FutureOr<Response> call(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.fetchRelated(this, query);

  void sendResource(Resource resource) {
    _response = RelatedResourceResponse(resource);
  }

  void sendCollection(Collection<Resource> collection,
      {Iterable<Resource> included = const [], Page page}) {
    _response =
        RelatedCollectionResponse(collection, included: included, page: page);
  }
}

class FetchRelationship extends Request {
  final RelationshipTarget target;

  FetchRelationship(this.target);

  @override
  FutureOr<void> call(Controller controller, Map<String, List<String>> query,
          Object payload) =>
      controller.fetchRelationship(this, query);

  void sendToOne(Identifier identifier) {
    _response = ToOneResponse(target, identifier);
  }

  void sendToMany(List<Identifier> collection) {
    _response = ToManyResponse(target, collection);
  }
}

class DeleteResource extends Request {
  final ResourceTarget target;

  DeleteResource(this.target);

  @override
  FutureOr<void> call(Controller controller, Map<String, List<String>> query,
          Object payload) =>
      controller.deleteResource(this);

  void sendNoContent() {
    _response = NoContent();
  }

  void sendMeta(Map<String, Object> map) {
    _response = MetaResponse(map);
  }
}

class UpdateResource extends Request {
  final ResourceTarget target;

  UpdateResource(this.target);

  @override
  FutureOr<void> call(Controller controller, Map<String, List<String>> query,
          Object payload) =>
      controller.updateResource(
          this,
          Document.decodeJson(payload, ResourceData.decodeJson)
              .data
              .resourceObject
              .unwrap());

  void sendNoContent() {
    _response = NoContent();
  }

  void sendUpdated(Resource resource) {
    _response = ResourceUpdated(resource);
  }
}

class CreateResource extends Request {
  final CollectionTarget target;

  CreateResource(this.target);

  @override
  FutureOr<void> call(Controller controller, Map<String, List<String>> query,
          Object payload) =>
      controller.createResource(
          this,
          Document.decodeJson(payload, ResourceData.decodeJson)
              .data
              .resourceObject
              .unwrap());

  void sendNoContent() {
    _response = NoContent();
  }

  void sendAccepted(Resource resource) {
    _response = Accepted(resource);
  }

  void sendCreated(Resource resource) {
    _response = ResourceCreated(resource);
  }
}

class UpdateRelationship extends Request {
  final RelationshipTarget target;

  UpdateRelationship(this.target);

  @override
  FutureOr<void> call(Controller controller, Map<String, List<String>> query,
      Object payload) async {
    final rel = Relationship.decodeJson(payload);
    if (rel is ToOne) {
      controller.replaceToOne(this, rel.toIdentifier());
    }
    if (rel is ToMany) {
      controller.replaceToMany(this, rel.identifiers);
    }
  }

  void sendNoContent() {
    _response = NoContent();
  }
}

class AddToMany extends Request {
  final RelationshipTarget target;

  AddToMany(this.target);

  @override
  FutureOr<void> call(Controller controller, Map<String, List<String>> query,
      Object payload) async {
    final rel = Relationship.decodeJson(payload);
    if (rel is ToMany) {
      controller.addToMany(this, rel.identifiers);
    }
  }

  void sendToMany(List<Identifier> identifiers) {
    _response = ToManyResponse(target, identifiers);
  }
}

class InvalidRequest extends Request {
  final target = null;

  InvalidRequest(ErrorResponse response) {
    _response = response;
  }

  @override
  void call(
      Controller controller, Map<String, List<String>> query, Object payload) {}
}
