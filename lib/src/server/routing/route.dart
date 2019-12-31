import 'package:json_api/document.dart';
import 'package:json_api/src/server/json_api_controller.dart';
import 'package:json_api/src/server/json_api_request.dart';

abstract class Route {
  Response call<Request extends JsonApiRequest, Response>(
      JsonApiController<Request, Response> controller, Request request);
}

class InvalidRoute implements Route {
  InvalidRoute();

  @override
  Response call<Request extends JsonApiRequest, Response>(
          JsonApiController<Request, Response> controller, Request request) =>
      null;
}

class ResourceRoute implements Route {
  final String type;
  final String id;

  ResourceRoute(this.type, this.id);

  @override
  Response call<Request extends JsonApiRequest, Response>(
      JsonApiController<Request, Response> controller, Request request) {
    final method = HttpMethod(request.method);
    if (method.isGet) {
      return controller.fetchResource(type, id, request);
    }
    if (method.isDelete) {
      return controller.deleteResource(type, id, request);
    }
    if (method.isPatch) {
      return controller.updateResource(
          type, id, ResourceData.fromJson(request.body).unwrap(), request);
    }
    return null;
  }
}

class CollectionRoute implements Route {
  final String type;

  CollectionRoute(this.type);

  @override
  Response call<Request extends JsonApiRequest, Response>(
      JsonApiController<Request, Response> controller, Request request) {
    final method = HttpMethod(request.method);
    if (method.isGet) {
      return controller.fetchCollection(type, request);
    }
    if (method.isPost) {
      return controller.createResource(
          type, ResourceData.fromJson(request.body).unwrap(), request);
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
  Response call<Request extends JsonApiRequest, Response>(
      JsonApiController<Request, Response> controller, Request request) {
    final method = HttpMethod(request.method);

    if (method.isGet) {
      return controller.fetchRelated(type, id, relationship, request);
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
  Response call<Request extends JsonApiRequest, Response>(
      JsonApiController<Request, Response> controller, Request request) {
    final method = HttpMethod(request.method);

    if (method.isGet) {
      return controller.fetchRelationship(type, id, relationship, request);
    }
    if (method.isPatch) {
      final rel = Relationship.fromJson(request.body);
      if (rel is ToOne) {
        return controller.replaceToOne(
            type, id, relationship, rel.unwrap(), request);
      }
      if (rel is ToMany) {
        return controller.replaceToMany(
            type, id, relationship, rel.unwrap(), request);
      }
    }
    if (method.isPost) {
      return controller.addToMany(type, id, relationship,
          ToMany.fromJson(request.body).unwrap(), request);
    }
    return null;
  }
}

class HttpMethod {
  final String _method;

  HttpMethod(String method) : _method = method.toUpperCase();

  bool get isGet => _method == 'GET';

  bool get isPost => _method == 'POST';

  bool get isPatch => _method == 'PATCH';

  bool get isDelete => _method == 'DELETE';
}
