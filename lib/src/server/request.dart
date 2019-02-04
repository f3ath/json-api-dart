import 'package:json_api/document.dart';
import 'package:json_api/src/server/response.dart';

abstract class JsonApiController {
  Future<ServerResponse> fetchCollection(CollectionRequest rq);

  Future<ServerResponse> fetchResource(ResourceRequest rq);

  Future<ServerResponse> createResource(CollectionRequest rq);

  Future<ServerResponse> fetchRelationship(RelationshipRequest rq);

  Future<ServerResponse> addRelationship(RelationshipRequest rq);

  Future<ServerResponse> fetchRelated(RelatedRequest rq);
}

abstract class JsonApiRequest {
  String get type;

  Future<ServerResponse> fulfill(JsonApiController controller);
}

class CollectionRequest implements JsonApiRequest {
  final String method;
  final String body;
  final String type;
  final Map<String, String> queryParameters;

  CollectionRequest(this.method, this.type, {this.body, this.queryParameters});

  Future<ServerResponse> fulfill(JsonApiController controller) async {
    switch (method.toUpperCase()) {
      case 'GET':
        return controller.fetchCollection(this);
      case 'POST':
        return controller.createResource(this);
    }
    return ServerResponse(405);
  }
}

class ResourceRequest<R> implements JsonApiRequest {
  final String type;
  final String id;

  ResourceRequest(this.type, this.id);

  Identifier get identifier => Identifier(type, id);

  Future<ServerResponse> fulfill(JsonApiController controller) =>
      controller.fetchResource(this);
}

class RelatedRequest implements JsonApiRequest {
  final String type;
  final String id;
  final String name;

  RelatedRequest(this.type, this.id, this.name);

  Identifier get identifier => Identifier(type, id);

  Future<ServerResponse> fulfill(JsonApiController controller) =>
      controller.fetchRelated(this);
}

class RelationshipRequest<R> implements JsonApiRequest {
  final String method;
  final String body;
  final String type;
  final String id;
  final String name;

  RelationshipRequest(this.method, this.type, this.id, this.name, {this.body});

  Identifier get identifier => Identifier(type, id);

  Future<ServerResponse> fulfill(JsonApiController controller) async {
    switch (method.toUpperCase()) {
      case 'GET':
        return controller.fetchRelationship(this);
      case 'POST':
        return controller.addRelationship(this);
    }
    return ServerResponse(405);
  }
}
