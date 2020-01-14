import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/src/server/controller/controller.dart';
import 'package:json_api/src/server/json_api_response.dart';
import 'package:json_api/src/server/target.dart';

abstract class ControllerRequest {
  /// Calls the appropriate method of the controller
  FutureOr<JsonApiResponse> call<R>(
      Controller<R> controller, Object jsonPayload, R request);
}

class ControllerRequestFactory implements RequestFactory<ControllerRequest> {
  const ControllerRequestFactory();

  @override
  ControllerRequest addToRelationship(RelationshipTarget target) =>
      _AddToRelationship(target);

  @override
  ControllerRequest createResource(CollectionTarget target) =>
      _CreateResource(target);

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
  FutureOr<JsonApiResponse> call<R>(
          Controller<R> controller, Object jsonPayload, R request) =>
      controller.addToRelationship(request, target.type, target.id,
          target.relationship, ToMany.fromJson(jsonPayload).unwrap());
}

class _DeleteFromRelationship implements ControllerRequest {
  final RelationshipTarget target;

  _DeleteFromRelationship(this.target);

  @override
  FutureOr<JsonApiResponse> call<R>(
          Controller<R> controller, Object jsonPayload, R request) =>
      controller.deleteFromRelationship(request, target.type, target.id,
          target.relationship, ToMany.fromJson(jsonPayload).unwrap());
}

class _UpdateResource implements ControllerRequest {
  final ResourceTarget target;

  _UpdateResource(this.target);

  @override
  FutureOr<JsonApiResponse> call<R>(
          Controller<R> controller, Object jsonPayload, R request) =>
      controller.updateResource(request, target.type, target.id,
          ResourceData.fromJson(jsonPayload).unwrap());
}

class _CreateResource implements ControllerRequest {
  final CollectionTarget target;

  _CreateResource(this.target);

  @override
  FutureOr<JsonApiResponse> call<R>(
          Controller<R> controller, Object jsonPayload, R request) =>
      controller.createResource(
          request, target.type, ResourceData.fromJson(jsonPayload).unwrap());
}

class _DeleteResource implements ControllerRequest {
  final ResourceTarget target;

  _DeleteResource(this.target);

  @override
  FutureOr<JsonApiResponse> call<R>(
          Controller<R> controller, Object jsonPayload, R request) =>
      controller.deleteResource(request, target.type, target.id);
}

class _FetchRelationship implements ControllerRequest {
  final RelationshipTarget target;

  _FetchRelationship(this.target);

  @override
  FutureOr<JsonApiResponse> call<R>(
          Controller<R> controller, Object jsonPayload, R request) =>
      controller.fetchRelationship(
          request, target.type, target.id, target.relationship);
}

class _FetchRelated implements ControllerRequest {
  final RelatedTarget target;

  _FetchRelated(this.target);

  @override
  FutureOr<JsonApiResponse> call<R>(
          Controller<R> controller, Object jsonPayload, R request) =>
      controller.fetchRelated(
          request, target.type, target.id, target.relationship);
}

class _FetchResource implements ControllerRequest {
  final ResourceTarget target;

  _FetchResource(this.target);

  @override
  FutureOr<JsonApiResponse> call<R>(
          Controller<R> controller, Object jsonPayload, R request) =>
      controller.fetchResource(request, target.type, target.id);
}

class _FetchCollection implements ControllerRequest {
  final CollectionTarget target;

  _FetchCollection(this.target);

  @override
  FutureOr<JsonApiResponse> call<R>(
          Controller<R> controller, Object jsonPayload, R request) =>
      controller.fetchCollection(request, target.type);
}

class _UpdateRelationship implements ControllerRequest {
  final RelationshipTarget target;

  _UpdateRelationship(this.target);

  @override
  FutureOr<JsonApiResponse> call<R>(
      Controller<R> controller, Object jsonPayload, R request) {
    final relationship = Relationship.fromJson(jsonPayload);
    if (relationship is ToOne) {
      return controller.replaceToOne(request, target.type, target.id,
          target.relationship, relationship.unwrap());
    }
    if (relationship is ToMany) {
      return controller.replaceToMany(request, target.type, target.id,
          target.relationship, relationship.unwrap());
    }
  }
}

class _InvalidRequest implements ControllerRequest {
  final Target target;
  final String method;

  _InvalidRequest(this.target, this.method);

  @override
  FutureOr<JsonApiResponse> call<R>(
      Controller<R> controller, Object jsonPayload, R request) {
    // TODO: implement call
    return null;
  }
}
