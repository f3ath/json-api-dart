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
  RequestTarget get target;

  FutureOr<Response> call(
      Controller controller, Map<String, List<String>> query, Object payload);

  Response errorNotFound(List<JsonApiError> errors) =>
      ErrorResponse.notFound(errors);

  Response errorConflict(List<JsonApiError> errors) =>
      ErrorResponse.conflict(errors);

  Response error(int status, List<JsonApiError> errors) =>
      ErrorResponse(status, errors);
}

class FetchCollection extends Request {
  final CollectionTarget target;

  FetchCollection(this.target);

  @override
  FutureOr<Response> call(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.fetchCollection(this, query);

  Response sendCollection(Collection<Resource> resources,
          {Iterable<Resource> included = const [], Page page}) =>
      CollectionResponse(resources, included: included, page: page);
}

class FetchResource extends Request {
  final ResourceTarget target;

  FetchResource(this.target);

  @override
  FutureOr<Response> call(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.fetchResource(this, query);

  Response sendResource(Resource resource, {Iterable<Resource> included}) =>
      ResourceResponse(resource, included: included);

  Response sendSeeOther(Resource resource) => SeeOther(resource);
}

class FetchRelated extends Request {
  final RelatedTarget target;

  FetchRelated(this.target);

  @override
  FutureOr<Response> call(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.fetchRelated(this, query);

  Response sendResource(Resource resource) => RelatedResourceResponse(resource);

  Response sendCollection(Collection<Resource> collection,
          {Iterable<Resource> included = const [], Page page}) =>
      RelatedCollectionResponse(collection, included: included, page: page);
}

class FetchRelationship extends Request {
  final RelationshipTarget target;

  FetchRelationship(this.target);

  @override
  FutureOr<Response> call(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.fetchRelationship(this, query);

  Response sendToOne(Identifier identifier) =>
      ToOneResponse(target, identifier);

  Response sendToMany(List<Identifier> collection) =>
      ToManyResponse(target, collection);
}

class DeleteResource extends Request {
  final ResourceTarget target;

  DeleteResource(this.target);

  @override
  FutureOr<Response> call(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.deleteResource(this);

  Response sendNoContent() => NoContent();

  Response sendMeta(Map<String, Object> map) => MetaResponse(map);
}

class UpdateResource extends Request {
  final ResourceTarget target;

  UpdateResource(this.target);

  @override
  FutureOr<Response> call(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.updateResource(
          this,
          Document.decodeJson(payload, ResourceData.decodeJson)
              .data
              .resourceObject
              .unwrap());

  Response sendNoContent() => NoContent();

  Response sendUpdated(Resource resource) => ResourceUpdated(resource);
}

class CreateResource extends Request {
  final CollectionTarget target;

  CreateResource(this.target);

  @override
  FutureOr<Response> call(Controller controller,
          Map<String, List<String>> query, Object payload) =>
      controller.createResource(
          this,
          Document.decodeJson(payload, ResourceData.decodeJson)
              .data
              .resourceObject
              .unwrap());

  Response sendNoContent() => NoContent();

  Response sendAccepted(Resource resource) => Accepted(resource);

  Response sendCreated(Resource resource) => ResourceCreated(resource);
}

class UpdateRelationship extends Request {
  final RelationshipTarget target;

  UpdateRelationship(this.target);

  @override
  FutureOr<Response> call(Controller controller,
      Map<String, List<String>> query, Object payload) async {
    final rel = Relationship.decodeJson(payload);
    if (rel is ToOne) {
      return controller.replaceToOne(this, rel.unwrap());
    }
    if (rel is ToMany) {
      return controller.replaceToMany(this, rel.identifiers);
    }
  }

  Response sendNoContent() => NoContent();
}

class AddToMany extends Request {
  final RelationshipTarget target;

  AddToMany(this.target);

  @override
  FutureOr<Response> call(Controller controller,
      Map<String, List<String>> query, Object payload) async {
    final rel = Relationship.decodeJson(payload);
    if (rel is ToMany) {
      return controller.addToMany(this, rel.identifiers);
    }
  }

  Response sendToMany(List<Identifier> identifiers) =>
      ToManyResponse(target, identifiers);
}

class InvalidRequest extends Request {
  final target = null;
  final Response _response;

  InvalidRequest(this._response);

  @override
  Response call(Controller controller, Map<String, List<String>> query,
          Object payload) =>
      _response;
}

class DefaultRequestFactory implements RequestFactory<Request> {
  const DefaultRequestFactory();

  @override
  FetchCollection makeFetchCollectionRequest(CollectionTarget target) =>
      FetchCollection(target);

  @override
  CreateResource makeCreateResourceRequest(CollectionTarget target) =>
      CreateResource(target);

  @override
  FetchResource makeFetchResourceRequest(ResourceTarget target) =>
      FetchResource(target);

  @override
  DeleteResource makeDeleteResourceRequest(ResourceTarget target) =>
      DeleteResource(target);

  @override
  UpdateResource makeUpdateResourceRequest(ResourceTarget target) =>
      UpdateResource(target);

  @override
  FetchRelationship makeFetchRelationshipRequest(RelationshipTarget target) =>
      FetchRelationship(target);

  @override
  AddToMany makeAddToManyRequest(RelationshipTarget target) =>
      AddToMany(target);

  @override
  FetchRelated makeFetchRelatedRequest(RelatedTarget target) =>
      FetchRelated(target);

  @override
  UpdateRelationship makeUpdateRelationshipRequest(RelationshipTarget target) =>
      UpdateRelationship(target);

  @override
  InvalidRequest makeInvalidRequest(RequestTarget target) =>
      InvalidRequest(ErrorResponse.methodNotAllowed([]));
}
