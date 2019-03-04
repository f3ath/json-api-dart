import 'dart:async';

import 'package:json_api/src/server/request.dart';
import 'package:json_api/src/server/response.dart';

/// JSON:API Controller
abstract class JsonApiController {
  Future<ServerResponse> fetchCollection(
      String type, JsonApiHttpRequest request);

  Future<ServerResponse> fetchResource(
      String type, String id, JsonApiHttpRequest request);

  Future<ServerResponse> fetchRelationship(
      String type, String id, String relationship, JsonApiHttpRequest request);

  Future<ServerResponse> fetchRelated(
      String type, String id, String relationship, JsonApiHttpRequest request);

  Future<ServerResponse> createResource(
      String type, JsonApiHttpRequest request);

  Future<ServerResponse> deleteResource(
      String type, String id, JsonApiHttpRequest request);

  Future<ServerResponse> updateResource(
      String type, String id, JsonApiHttpRequest request);

  Future<ServerResponse> replaceRelationship(
      String type, String id, String relationship, JsonApiHttpRequest request);

  Future<ServerResponse> addToMany(
      String type, String id, String relationship, JsonApiHttpRequest request);
}
