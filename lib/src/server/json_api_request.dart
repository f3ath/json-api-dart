import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/src/server/json_api_controller.dart';
import 'package:json_api/src/server/json_api_response.dart';

abstract class JsonApiRequest {
  /// Calls the appropriate method of [controller]
  FutureOr<JsonApiResponse> call<R>(
      JsonApiController<R> controller, Object jsonPayload, R request);

  static JsonApiRequest fetchCollection(String type) => _FetchCollection(type);

  static JsonApiRequest createResource(String type) => _CreateResource(type);

  /// Creates a request which always returns the [response]
  static JsonApiRequest predefinedResponse(JsonApiResponse response) =>
      _PredefinedResponse(response);

  static JsonApiRequest fetchResource(String type, String id) =>
      _FetchResource(type, id);

  static JsonApiRequest deleteResource(String type, String id) =>
      _DeleteResource(type, id);

  static JsonApiRequest updateResource(String type, String id) =>
      _UpdateResource(type, id);

  static JsonApiRequest fetchRelated(
          String type, String id, String relationship) =>
      _FetchRelated(type, id, relationship);

  static JsonApiRequest fetchRelationship(
          String type, String id, String relationship) =>
      _FetchRelationship(type, id, relationship);

  static JsonApiRequest updateRelationship(
          String type, String id, String relationship) =>
      _UpdateRelationship(type, id, relationship);

  static JsonApiRequest addToRelationship(
          String type, String id, String relationship) =>
      _AddToRelationship(type, id, relationship);

  static JsonApiRequest deleteFromRelationship(
          String type, String id, String relationship) =>
      _DeleteFromRelationship(type, id, relationship);
}

/// Exception thrown by [JsonApiRequest] when an `updateRelationship` request
/// receives an incomplete relationship object.
class IncompleteRelationshipException implements Exception {}

class _AddToRelationship implements JsonApiRequest {
  final String type;
  final String id;
  final String relationship;

  @override
  FutureOr<JsonApiResponse> call<R>(
          JsonApiController<R> controller, Object jsonPayload, R request) =>
      controller.addToRelationship(request, type, id, relationship,
          ToMany.fromJson(jsonPayload).unwrap());

  _AddToRelationship(this.type, this.id, this.relationship);
}

class _CreateResource implements JsonApiRequest {
  final String type;

  @override
  FutureOr<JsonApiResponse> call<R>(
          JsonApiController<R> controller, Object jsonPayload, R request) =>
      controller.createResource(
          request, type, ResourceData.fromJson(jsonPayload).unwrap());

  _CreateResource(this.type);
}

class _DeleteFromRelationship implements JsonApiRequest {
  final String type;
  final String id;
  final String relationship;

  @override
  FutureOr<JsonApiResponse> call<R>(
          JsonApiController<R> controller, Object jsonPayload, R request) =>
      controller.deleteFromRelationship(request, type, id, relationship,
          ToMany.fromJson(jsonPayload).unwrap());

  _DeleteFromRelationship(this.type, this.id, this.relationship);
}

class _DeleteResource implements JsonApiRequest {
  final String type;
  final String id;

  @override
  FutureOr<JsonApiResponse> call<R>(
          JsonApiController<R> controller, Object jsonPayload, R request) =>
      controller.deleteResource(request, type, id);

  _DeleteResource(this.type, this.id);
}

class _FetchCollection implements JsonApiRequest {
  final String type;

  @override
  FutureOr<JsonApiResponse> call<R>(
          JsonApiController<R> controller, Object jsonPayload, R request) =>
      controller.fetchCollection(request, type);

  _FetchCollection(this.type);
}

class _FetchRelated implements JsonApiRequest {
  final String type;
  final String id;
  final String relationship;

  @override
  FutureOr<JsonApiResponse> call<R>(
          JsonApiController<R> controller, Object jsonPayload, R request) =>
      controller.fetchRelated(request, type, id, relationship);

  _FetchRelated(this.type, this.id, this.relationship);
}

class _FetchRelationship implements JsonApiRequest {
  final String type;
  final String id;
  final String relationship;

  @override
  FutureOr<JsonApiResponse> call<R>(
          JsonApiController<R> controller, Object jsonPayload, R request) =>
      controller.fetchRelationship(request, type, id, relationship);

  _FetchRelationship(this.type, this.id, this.relationship);
}

class _FetchResource implements JsonApiRequest {
  final String type;
  final String id;

  @override
  FutureOr<JsonApiResponse> call<R>(
          JsonApiController<R> controller, Object jsonPayload, R request) =>
      controller.fetchResource(request, type, id);

  _FetchResource(this.type, this.id);
}

class _PredefinedResponse implements JsonApiRequest {
  final JsonApiResponse response;

  @override
  FutureOr<JsonApiResponse> call<R>(
          JsonApiController<R> controller, Object jsonPayload, R request) =>
      response;

  _PredefinedResponse(this.response);
}

class _UpdateRelationship implements JsonApiRequest {
  final String type;
  final String id;
  final String relationship;

  @override
  FutureOr<JsonApiResponse> call<R>(
      JsonApiController<R> controller, Object jsonPayload, R request) {
    final r = Relationship.fromJson(jsonPayload);
    if (r is ToOne) {
      return controller.replaceToOne(
          request, type, id, relationship, r.unwrap());
    }
    if (r is ToMany) {
      return controller.replaceToMany(
          request, type, id, relationship, r.unwrap());
    }
    throw IncompleteRelationshipException();
  }

  _UpdateRelationship(this.type, this.id, this.relationship);
}

class _UpdateResource implements JsonApiRequest {
  final String type;
  final String id;

  _UpdateResource(this.type, this.id);

  @override
  FutureOr<JsonApiResponse> call<R>(
          JsonApiController<R> controller, Object jsonPayload, R request) =>
      controller.updateResource(
          request, type, id, ResourceData.fromJson(jsonPayload).unwrap());
}
