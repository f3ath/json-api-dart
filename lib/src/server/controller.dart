import 'dart:async';
import 'dart:io';

import 'package:json_api/document.dart';
import 'package:json_api/src/server/collection.dart';
import 'package:json_api/src/server/request_target.dart';

abstract class JsonApiController {
  Future<void> fetchCollection(
      ControllerRequest<CollectionTarget, void> request,
      FetchCollectionResponse response);

  Future<void> fetchRelated(ControllerRequest<RelatedTarget, void> request,
      FetchRelatedResponse response);

  Future<void> fetchResource(ControllerRequest<ResourceTarget, void> request,
      FetchResourceResponse response);

  Future<void> fetchRelationship(
      ControllerRequest<RelationshipTarget, void> request,
      FetchRelationshipResponse response);

  Future<void> deleteResource(ControllerRequest<ResourceTarget, void> request,
      DeleteResourceResponse response);

  Future<void> createResource(
      ControllerRequest<CollectionTarget, Resource> request,
      CreateResourceResponse response);

  Future<void> updateResource(
      ControllerRequest<ResourceTarget, Resource> request,
      UpdateResourceResponse response);

  Future<void> replaceToOne(
      ControllerRequest<RelationshipTarget, Identifier> request,
      ReplaceToOneResponse response);

  Future<void> replaceToMany(
      ControllerRequest<RelationshipTarget, Iterable<Identifier>> request,
      ReplaceToManyResponse response);

  Future<void> addToMany(
      ControllerRequest<RelationshipTarget, Iterable<Identifier>> request,
      AddToManyResponse response);
}

class ControllerRequest<T extends RequestTarget, P> {
  final HttpRequest _request;
  final P payload;

  final T target;

  ControllerRequest(this._request, this.target, {this.payload});

  Uri get uri => _request.requestedUri;

  HttpHeaders get headers => _request.headers;
}

abstract class ControllerResponse {
  /// Headers to be sent in the response
  final headers = <String, String>{};

  Future<void> errorNotFound(Iterable<JsonApiError> errors);

  Future<void> errorBadRequest(Iterable<JsonApiError> errors);
}

abstract class FetchCollectionResponse extends ControllerResponse {
  Future<void> sendCollection(Collection<Resource> resources);
}

abstract class CreateResourceResponse extends ControllerResponse {
  Future<void> sendCreated(Resource resource);

  Future<void> sendNoContent();

  Future<void> errorConflict(Iterable<JsonApiError> errors);

  Future<void> sendAccepted(Resource asyncJob);
}

abstract class FetchResourceResponse extends ControllerResponse {
  /// https://jsonapi.org/recommendations/#asynchronous-processing
  Future<void> sendSeeOther(Resource resource);

  Future<void> sendResource(Resource resource, {Iterable<Resource> included});
}

abstract class DeleteResourceResponse extends ControllerResponse {
  Future<void> sendNoContent();

  Future<void> sendMeta(Map<String, Object> meta);
}

abstract class UpdateResourceResponse extends ControllerResponse {
  Future<void> sendUpdated(Resource resource);

  Future<void> sendNoContent();

  Future<void> sendAccepted(Resource asyncJob);

  Future<void> errorConflict(Iterable<JsonApiError> errors);

  Future<void> errorForbidden(Iterable<JsonApiError> errors);
}

abstract class FetchRelationshipResponse extends ControllerResponse {
  Future<void> sendToMany(Iterable<Identifier> collection);

  Future<void> sendToOne(Identifier id);
}

abstract class ReplaceToOneResponse extends ControllerResponse {
  Future<void> sendNoContent();

  Future<void> sendAccepted(Resource asyncJob);

  Future<void> sendToMany(Iterable<Identifier> collection);

  Future<void> sendToOne(Identifier id);
}

abstract class ReplaceToManyResponse extends ControllerResponse {
  Future<void> sendNoContent();

  Future<void> sendAccepted(Resource asyncJob);

  Future<void> sendToMany(Iterable<Identifier> collection);

  Future<void> sendToOne(Identifier id);
}

abstract class AddToManyResponse extends ControllerResponse {
  Future<void> sendAccepted(Resource asyncJob);

  Future<void> sendToMany(Iterable<Identifier> collection);
}

abstract class FetchRelatedResponse extends ControllerResponse {
  Future<void> sendCollection(Collection<Resource> resources);

  Future<void> sendResource(Resource resource);
}
