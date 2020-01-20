import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/server.dart';

class JsonApiControllerBase<R> implements JsonApiController<R> {
  @override
  FutureOr<JsonApiResponse> addToRelationship(R request, String type, String id,
      String relationship, Iterable<Identifier> identifiers) {
    throw _forbidden;
  }

  @override
  FutureOr<JsonApiResponse> createResource(
      request, String type, Resource resource) {
    throw _forbidden;
  }

  @override
  FutureOr<JsonApiResponse> deleteFromRelationship(R request, String type,
      String id, String relationship, Iterable<Identifier> identifiers) {
    throw _forbidden;
  }

  @override
  FutureOr<JsonApiResponse> deleteResource(R request, String type, String id) {
    throw _forbidden;
  }

  @override
  FutureOr<JsonApiResponse> fetchCollection(R request, String type) {
    throw _forbidden;
  }

  @override
  FutureOr<JsonApiResponse> fetchRelated(
      request, String type, String id, String relationship) {
    throw _forbidden;
  }

  @override
  FutureOr<JsonApiResponse> fetchRelationship(
      request, String type, String id, String relationship) {
    throw _forbidden;
  }

  @override
  FutureOr<JsonApiResponse> fetchResource(R request, String type, String id) {
    throw _forbidden;
  }

  @override
  FutureOr<JsonApiResponse> replaceToMany(R request, String type, String id,
      String relationship, Iterable<Identifier> identifiers) {
    throw _forbidden;
  }

  @override
  FutureOr<JsonApiResponse> replaceToOne(R request, String type, String id,
      String relationship, Identifier identifier) {
    throw _forbidden;
  }

  @override
  FutureOr<JsonApiResponse> updateResource(
      request, String type, String id, Resource resource) {
    throw _forbidden;
  }

  final _forbidden = JsonApiResponse.forbidden([
    JsonApiError(
        status: '403',
        detail: 'This request is not supported by the server',
        title: '403 Forbidden')
  ]);
}
