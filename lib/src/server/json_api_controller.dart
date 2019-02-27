import 'dart:async';

import 'package:json_api/src/server/response.dart';

/// JSON:API Controller
abstract class JsonApiController {
  Future<ServerResponse> fetchCollection(
      String type, Map<String, String> params);

  Future<ServerResponse> fetchResource(String type, String id);

  Future<ServerResponse> fetchRelationship(
      String type, String id, String relationship);

  Future<ServerResponse> fetchRelated(
      String type, String id, String relationship);
}
