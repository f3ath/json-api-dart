import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/src/server/response/json_api_response.dart';
import 'package:json_api/src/server/target.dart';

abstract class JsonApiController<R> {
  FutureOr<ControllerResponse> fetchCollection(R request, String type);

  FutureOr<ControllerResponse> fetchResource(R request, String type, String id);

  FutureOr<ControllerResponse> fetchRelated(
      R request, String type, String id, String relationship);

  FutureOr<ControllerResponse> fetchRelationship(
      R request, String type, String id, String relationship);

  FutureOr<ControllerResponse> deleteResource(
      R request, String type, String id);

  FutureOr<ControllerResponse> createResource(
      R request, String type, Resource resource);

  FutureOr<ControllerResponse> updateResource(
      R request, String type, String id);

  FutureOr<ControllerResponse> updateToOne(
      R request, String type, String id, String relationship);

  FutureOr<ControllerResponse> updateToMany(
      R request, String type, String id, String relationship);

  FutureOr<ControllerResponse> deleteFromRelationship(
      R request, String type, String id, String relationship);

  FutureOr<ControllerResponse> addToRelationship(
      R request, String type, String id, String relationship);
}

abstract class ControllerRequest {
  /// Calls the appropriate method of the controller
  FutureOr<ControllerResponse> call<R>(
      JsonApiController<R> controller, Object jsonPayload, R request);
}

class ControllerRequestFactory implements RequestFactory<ControllerRequest> {
  const ControllerRequestFactory();

  @override
  ControllerRequest addToRelationship(RelationshipTarget target) =>
      _AddToRelationship(target);

  @override
  ControllerRequest createResource(CollectionTarget target) =>
      CreateResource(target);

  @override
  ControllerRequest deleteFromRelationship(RelationshipTarget target) =>
      _DeleteFromRelationship(target);

  @override
  ControllerRequest deleteResource(ResourceTarget target) =>
      _DeleteResource(target);

  @override
  ControllerRequest fetchCollection(CollectionTarget target) =>
      _FetchCollection(target);

  @override
  ControllerRequest fetchRelated(RelatedTarget target) => _FetchRelated(target);

  @override
  ControllerRequest fetchRelationship(RelationshipTarget target) =>
      _FetchRelationship(target);

  @override
  ControllerRequest fetchResource(ResourceTarget target) =>
      _FetchResource(target);

  @override
  ControllerRequest invalid(Target target, String method) =>
      _InvalidRequest(target, method);

  @override
  ControllerRequest updateRelationship(RelationshipTarget target) =>
      _UpdateRelationship(target);

  @override
  ControllerRequest updateResource(ResourceTarget target) =>
      _UpdateResource(target);
}

class _AddToRelationship implements ControllerRequest {
  final RelationshipTarget target;

  _AddToRelationship(this.target);

  @override
  FutureOr<ControllerResponse> call<R>(
      JsonApiController<R> controller, Object jsonPayload, R request) {
    // TODO: implement call
    return null;
  }
}

class _DeleteFromRelationship implements ControllerRequest {
  _DeleteFromRelationship(RelationshipTarget target);

  @override
  FutureOr<ControllerResponse> call<R>(
      JsonApiController<R> controller, Object jsonPayload, R request) {
    // TODO: implement call
    return null;
  }
}

class _UpdateResource implements ControllerRequest {
  final ResourceTarget target;

  _UpdateResource(this.target);

  @override
  FutureOr<ControllerResponse> call<R>(
      JsonApiController<R> controller, Object jsonPayload, R request) {
    // TODO: implement call
    return null;
  }
}

class CreateResource implements ControllerRequest {
  final CollectionTarget target;

  CreateResource(this.target);

  @override
  FutureOr<ControllerResponse> call<R>(
          JsonApiController<R> controller, Object jsonPayload, R request) =>
      controller.createResource(
          request, target.type, ResourceData.fromJson(jsonPayload).unwrap());
}

class _DeleteResource implements ControllerRequest {
  final ResourceTarget target;

  _DeleteResource(this.target);

  @override
  FutureOr<ControllerResponse> call<R>(
          JsonApiController<R> controller, Object jsonPayload, R request) =>
      controller.deleteResource(request, target.type, target.id);
}

class _FetchRelationship implements ControllerRequest {
  final RelationshipTarget target;

  _FetchRelationship(this.target);

  @override
  FutureOr<ControllerResponse> call<R>(
      JsonApiController<R> controller, Object jsonPayload, R request) {
    // TODO: implement call
    return null;
  }
}

class _FetchRelated implements ControllerRequest {
  final RelatedTarget target;

  _FetchRelated(this.target);

  @override
  FutureOr<ControllerResponse> call<R>(
          JsonApiController<R> controller, Object jsonPayload, R request) =>
      controller.fetchRelated(
          request, target.type, target.id, target.relationship);
}

class _FetchResource implements ControllerRequest {
  final ResourceTarget target;

  _FetchResource(this.target);

  @override
  FutureOr<ControllerResponse> call<R>(
          JsonApiController<R> controller, Object jsonPayload, R request) =>
      controller.fetchResource(request, target.type, target.id);
}

class _FetchCollection implements ControllerRequest {
  final CollectionTarget target;

  _FetchCollection(this.target);

  @override
  FutureOr<ControllerResponse> call<R>(
          JsonApiController<R> controller, Object jsonPayload, R request) =>
      controller.fetchCollection(request, target.type);
}

class _UpdateRelationship implements ControllerRequest {
  final RelationshipTarget target;

  _UpdateRelationship(this.target);

  @override
  FutureOr<ControllerResponse> call<R>(
      JsonApiController<R> controller, Object jsonPayload, R request) {
    return null;
  }
}

class _InvalidRequest implements ControllerRequest {
  final Target target;
  final String method;

  _InvalidRequest(this.target, this.method);

  @override
  FutureOr<ControllerResponse> call<R>(
      JsonApiController<R> controller, Object jsonPayload, R request) {
    // TODO: implement call
    return null;
  }
}
