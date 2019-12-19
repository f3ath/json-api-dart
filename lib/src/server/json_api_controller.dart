import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/server/response/json_api_response.dart';

abstract class JsonApiController {
  FutureOr<JsonApiResponse> fetchCollection(String type, Uri uri);

  FutureOr<JsonApiResponse> fetchResource(String type, String id, Uri uri);

  FutureOr<JsonApiResponse> fetchRelated(
      String type, String id, String relationship, Uri uri);

  FutureOr<JsonApiResponse> fetchRelationship(
      String type, String id, String relationship, Uri uri);

  FutureOr<JsonApiResponse> deleteResource(String type, String id);

  FutureOr<JsonApiResponse> createResource(String type, Resource resource);

  FutureOr<JsonApiResponse> updateResource(
      String type, String id, Resource resource);

  FutureOr<JsonApiResponse> replaceToOne(
      String type, String id, String relationship, Identifier identifier);

  FutureOr<JsonApiResponse> replaceToMany(String type, String id,
      String relationship, List<Identifier> identifiers);

  FutureOr<JsonApiResponse> addToMany(String type, String id,
      String relationship, List<Identifier> identifiers);
}
