import 'dart:async';

import 'package:json_api/src/server/request.dart';
import 'package:json_api/src/server/response.dart';

/// JSON:API Controller
abstract class JsonApiController {
  Future<ServerResponse> fetchCollection(CollectionRequest rq);

  Future<ServerResponse> fetchResource(ResourceRequest rq);

  Future<ServerResponse> fetchRelationship(RelationshipRequest rq);

  Future<ServerResponse> fetchRelated(RelatedRequest rq);

  Future<ServerResponse> createResource(CollectionRequest rq);
}
