import 'dart:async';

import 'package:collection/collection.dart';
import 'package:json_api/src/server/json_api_controller.dart';
import 'package:json_api/src/server/request.dart';
import 'package:json_api/src/server/response.dart';

/// Routing defines the design of URLs.
abstract class Router {
  /// Builds a URI for a resource collection
  Uri collection(String type, {Map<String, String> params});

  /// Builds a URI for a single resource
  Uri resource(String type, String id);

  /// Builds a URI for a related resource
  Uri related(String type, String id, String relationship);

  /// Builds a URI for a relationship object
  Uri relationship(String type, String id, String relationship);

  /// Resolves HTTP request to [JsonAiRequest] object
  Future<JsonApiRoute> resolve(JsonApiHttpRequest httpRequest);
}

/// StandardRouting implements the recommended URL design schema:
///
/// /photos - for a collection
/// /photos/1 - for a resource
/// /photos/1/relationships/author - for a relationship
/// /photos/1/author - for a related resource
///
/// See https://jsonapi.org/recommendations/#urls
class StandardRouting implements Router {
  final Uri base;

  StandardRouting(this.base) {
    ArgumentError.checkNotNull(base, 'base');
  }

  collection(String type, {Map<String, String> params}) => base.replace(
      pathSegments: base.pathSegments + [type],
      queryParameters:
          _nonEmpty(CombinedMapView([base.queryParameters, params ?? {}])));

  related(String type, String id, String relationship) =>
      base.replace(pathSegments: base.pathSegments + [type, id, relationship]);

  relationship(String type, String id, String relationship) => base.replace(
      pathSegments:
          base.pathSegments + [type, id, 'relationships', relationship]);

  resource(String type, String id) =>
      base.replace(pathSegments: base.pathSegments + [type, id]);

  Future<JsonApiRoute> resolve(JsonApiHttpRequest httpRequest) async {
    final seg = httpRequest.uri.pathSegments;
    switch (seg.length) {
      case 1:
        return CollectionRoute(seg[0]);
      case 2:
        return ResourceRoute(seg[0], seg[1]);
      case 3:
        return RelatedRoute(seg[0], seg[1], seg[2]);
      case 4:
        if (seg[2] == 'relationships') {
          return RelationshipRoute(seg[0], seg[1], seg[3]);
        }
    }
    return null; // TODO: replace with a null-object
  }

  Map<K, V> _nonEmpty<K, V>(Map<K, V> map) => map.isEmpty ? null : map;
}


abstract class JsonApiRoute {
  String get type;

  Future<ServerResponse> call(
      JsonApiController controller, JsonApiHttpRequest request);
}

class CollectionRoute implements JsonApiRoute {
  final String type;

  CollectionRoute(this.type);

  Future<ServerResponse> call(
      JsonApiController controller, JsonApiHttpRequest request) {
    switch (request.method) {
      case HttpMethod.get:
        return controller.fetchCollection(type, request);
      case HttpMethod.post:
        return controller.createResource(type, request);
      default:
        return Future.value(ServerResponse(405)); // TODO: meaningful error
    }
  }
}

class ResourceRoute implements JsonApiRoute {
  final String type;
  final String id;

  ResourceRoute(this.type, this.id);

  Future<ServerResponse> call(
      JsonApiController controller, JsonApiHttpRequest request) {
    switch (request.method) {
      case HttpMethod.get:
        return controller.fetchResource(type, id, request);
      case HttpMethod.delete:
        return controller.deleteResource(type, id, request);
      default:
        return Future.value(ServerResponse(405)); // TODO: meaningful error
    }
  }
}

class RelatedRoute implements JsonApiRoute {
  final String type;
  final String id;
  final String relationship;

  RelatedRoute(this.type, this.id, this.relationship);

  Future<ServerResponse> call(
      JsonApiController controller, JsonApiHttpRequest request) {
    switch (request.method) {
      case HttpMethod.get:
        return controller.fetchRelated(type, id, relationship, request);
      default:
        return Future.value(ServerResponse(405)); // TODO: meaningful error
    }
  }
}

class RelationshipRoute implements JsonApiRoute {
  final String type;
  final String id;
  final String relationship;

  RelationshipRoute(this.type, this.id, this.relationship);

  Future<ServerResponse> call(
      JsonApiController controller, JsonApiHttpRequest request) {
    switch (request.method) {
      case HttpMethod.get:
        return controller.fetchRelationship(type, id, relationship, request);
      default:
        return Future.value(ServerResponse(405)); // TODO: meaningful error
    }
  }
}
