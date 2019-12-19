import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/src/server/http_method.dart';
import 'package:json_api/src/server/json_api_controller.dart';
import 'package:json_api/src/server/response/json_api_response.dart';

abstract class Route {
  FutureOr<JsonApiResponse> call(
      JsonApiController controller, Uri uri, HttpMethod method, Object body);
}

class InvalidRoute implements Route {
  InvalidRoute();

  @override
  Future<JsonApiResponse> call(JsonApiController controller, Uri uri,
          HttpMethod method, Object body) =>
      null;
}

class ResourceRoute implements Route {
  final String type;
  final String id;

  ResourceRoute(this.type, this.id);

  @override
  FutureOr<JsonApiResponse> call(
      JsonApiController controller, Uri uri, HttpMethod method, Object body) {
    if (method.isGet()) {
      return controller.fetchResource(type, id, uri);
    }
    if (method.isDelete()) {
      return controller.deleteResource(type, id);
    }
    if (method.isPatch()) {
      return controller.updateResource(type, id,
          Document.fromJson(body, ResourceData.fromJson).data.unwrap());
    }
    return null;
  }
}

class CollectionRoute implements Route {
  final String type;

  CollectionRoute(this.type);

  @override
  FutureOr<JsonApiResponse> call(
      JsonApiController controller, Uri uri, HttpMethod method, Object body) {
    if (method.isGet()) {
      return controller.fetchCollection(type, uri);
    }
    if (method.isPost()) {
      return controller.createResource(
          type, Document.fromJson(body, ResourceData.fromJson).data.unwrap());
    }
    return null;
  }
}

class RelatedRoute implements Route {
  final String type;
  final String id;
  final String relationship;

  const RelatedRoute(this.type, this.id, this.relationship);

  @override
  FutureOr<JsonApiResponse> call(
      JsonApiController controller, Uri uri, HttpMethod method, Object body) {
    if (method.isGet()) {
      return controller.fetchRelated(type, id, relationship, uri);
    }
    return null;
  }
}

class RelationshipRoute implements Route {
  final String type;
  final String id;
  final String relationship;

  RelationshipRoute(this.type, this.id, this.relationship);

  @override
  FutureOr<JsonApiResponse> call(
      JsonApiController controller, Uri uri, HttpMethod method, Object body) {
    if (method.isGet()) {
      return controller.fetchRelationship(type, id, relationship, uri);
    }
    if (method.isPatch()) {
      final rel = Relationship.fromJson(body);
      if (rel is ToOne) {
        return controller.replaceToOne(type, id, relationship, rel.unwrap());
      }
      if (rel is ToMany) {
        return controller.replaceToMany(
            type, id, relationship, rel.identifiers);
      }
    }
    if (method.isPost()) {
      final rel = Relationship.fromJson(body);
      if (rel is ToMany) {
        return controller.addToMany(type, id, relationship, rel.identifiers);
      }
    }
    return null;
  }
}
