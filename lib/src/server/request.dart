import 'dart:async';

import 'package:json_api/src/server/json_api_controller.dart';
import 'package:json_api/src/server/response.dart';

abstract class JsonApiRequest {
  String get type;

  String get method;

  Future<ServerResponse> fulfill(JsonApiController controller);
}

class CollectionRequest implements JsonApiRequest {
  final String method;
  final String body;
  final String type;
  final Map<String, String> params;

  CollectionRequest(this.method, this.type, {this.body, this.params});

  Future<ServerResponse> fulfill(JsonApiController controller) async {
    switch (method.toUpperCase()) {
      case 'GET':
        return controller.fetchCollection(type, params);
//      case 'POST':
//        return controller.createResource(body);
    }
    return ServerResponse(405); // TODO: meaningful error
  }
}

class ResourceRequest<R> implements JsonApiRequest {
  final String method;
  final String body;
  final String type;
  final String id;

  ResourceRequest(this.method, this.type, this.id, {this.body});

  Future<ServerResponse> fulfill(JsonApiController controller) async {
    switch (method.toUpperCase()) {
      case 'GET':
        return controller.fetchResource(type, id);
//      case 'PATCH':
//        return controller.updateResource(type, id, body);
    }
    return ServerResponse(405); // TODO: meaningful error
  }
}

class RelatedRequest implements JsonApiRequest {
  final String method;
  final String type;
  final String id;
  final String relationship;
  final Map<String, String> params;

  RelatedRequest(this.method, this.type, this.id, this.relationship,
      {this.params});

  Future<ServerResponse> fulfill(JsonApiController controller) =>
      controller.fetchRelated(type, id, relationship);
}

class RelationshipRequest<R> implements JsonApiRequest {
  final String method;
  final String body;
  final String type;
  final String id;
  final String relationship;

  RelationshipRequest(this.method, this.type, this.id, this.relationship,
      {this.body});

  Future<ServerResponse> fulfill(JsonApiController controller) async {
    switch (method.toUpperCase()) {
      case 'GET':
        return controller.fetchRelationship(type, id, relationship);
//      case 'POST':
//        return controller.addToMany(type, id, relationship, body);
    }
    return ServerResponse(405); // TODO: meaningful error
  }
}
