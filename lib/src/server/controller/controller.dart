import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/server/json_api_response.dart';

abstract class Controller<R> {
  FutureOr<JsonApiResponse> fetchCollection(R request, String type);

  FutureOr<JsonApiResponse> fetchResource(R request, String type, String id);

  FutureOr<JsonApiResponse> fetchRelated(
      R request, String type, String id, String relationship);

  FutureOr<JsonApiResponse> fetchRelationship(
      R request, String type, String id, String relationship);

  FutureOr<JsonApiResponse> deleteResource(R request, String type, String id);

  FutureOr<JsonApiResponse> createResource(
      R request, String type, Resource resource);

  FutureOr<JsonApiResponse> updateResource(
      R request, String type, String id, Resource resource);

  FutureOr<JsonApiResponse> replaceToOne(R request, String type, String id,
      String relationship, Identifier identifier);

  FutureOr<JsonApiResponse> replaceToMany(R request, String type, String id,
      String relationship, Iterable<Identifier> identifiers);

  FutureOr<JsonApiResponse> deleteFromRelationship(R request, String type,
      String id, String relationship, Iterable<Identifier> identifiers);

  FutureOr<JsonApiResponse> addToRelationship(R request, String type, String id,
      String relationship, Iterable<Identifier> identifiers);
}
