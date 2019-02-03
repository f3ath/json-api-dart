import 'package:json_api/document.dart';
import 'package:json_api/src/server/response.dart';

abstract class JsonApiController {
  Future<ServerResponse> fetchCollection(CollectionRequest rq);

  Future<ServerResponse> fetchResource(ResourceRequest rq);

  Future<ServerResponse> fetchRelated(RelatedRequest rq);

  Future<ServerResponse> fetchRelationship(RelationshipRequest rq);
}

abstract class JsonApiRequest {
  String get type;

  Future<ServerResponse> perform(JsonApiController controller);
}

class CollectionRequest implements JsonApiRequest {
  final String type;
  final Map<String, String> queryParameters;

  CollectionRequest(this.type, {this.queryParameters});

  Future<ServerResponse> perform(JsonApiController controller) =>
      controller.fetchCollection(this);
}

class ResourceRequest<R> implements JsonApiRequest {
  final String type;
  final String id;

  ResourceRequest(this.type, this.id);

  Identifier get identifier => Identifier(type, id);

  Future<ServerResponse> perform(JsonApiController controller) =>
      controller.fetchResource(this);
}

class RelatedRequest implements JsonApiRequest {
  final String type;
  final String id;
  final String name;

  RelatedRequest(this.type, this.id, this.name);

  Identifier get identifier => Identifier(type, id);

  Future<ServerResponse> perform(JsonApiController controller) =>
      controller.fetchRelated(this);
}

class RelationshipRequest<R> implements JsonApiRequest {
  final String type;
  final String id;
  final String name;

  RelationshipRequest(this.type, this.id, this.name);

  Identifier get identifier => Identifier(type, id);

  Future<ServerResponse> perform(JsonApiController controller) =>
      controller.fetchRelationship(this);
}
