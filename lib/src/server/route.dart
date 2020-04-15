import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/request.dart';
import 'package:json_api/src/server/response.dart';
import 'package:json_api/src/server/target.dart';

abstract class Route<T extends CollectionTarget> {
  List<String> get allowedMethods;

  T get target;

  Future<Response> dispatch(HttpRequest request, Controller controller);

  Uri self(UriFactory uriFactory);
}


class CorsEnabled<T extends CollectionTarget> implements Route<T> {
  CorsEnabled(this._route);

  final Route<T> _route;

  @override
  List<String> get allowedMethods => _route.allowedMethods + ['OPTIONS'];

  @override
  Future<Response> dispatch(HttpRequest request, Controller controller) async {
    if (request.isOptions) {
      return ExtraHeaders(NoContentResponse(), {
        'Access-Control-Allow-Methods': allowedMethods.join(', '),
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Max-Age': '3600',
      });
    }
    return ExtraHeaders(await _route.dispatch(request, controller),
        {'Access-Control-Allow-Origin': '*'});
  }

  @override
  Uri self(UriFactory uriFactory) => _route.self(uriFactory);

  @override
  T get target => _route.target;
}

class CollectionRoute implements Route<CollectionTarget> {
  CollectionRoute(this.target);

  @override
  final CollectionTarget target;

  @override
  final allowedMethods = ['GET', 'POST'];

  @override
  Future<Response> dispatch(HttpRequest request, Controller controller) {
    final r = Request(request, this);
    if (request.isGet) {
      return controller.fetchCollection(r);
    }
    if (request.isPost) {
      return controller.createResource(
          r, ResourceData.fromJson(r.decodePayload()).unwrap());
    }
    throw ArgumentError();
  }

  @override
  Uri self(UriFactory uriFactory) => uriFactory.collection(target.type);
}

class ResourceRoute implements Route<ResourceTarget> {
  ResourceRoute(this.target);

  @override
  final ResourceTarget target;

  @override
  final allowedMethods = ['DELETE', 'GET', 'PATCH'];

  @override
  Future<Response> dispatch(HttpRequest request, Controller controller) {
    final r = Request(request, this);
    if (request.isDelete) {
      return controller.deleteResource(r);
    }
    if (request.isGet) {
      return controller.fetchResource(r);
    }
    if (request.isPatch) {
      return controller.updateResource(
          r, ResourceData.fromJson(r.decodePayload()).unwrap());
    }
    throw ArgumentError();
  }

  @override
  Uri self(UriFactory uriFactory) =>
      uriFactory.resource(target.type, target.id);
}

class RelatedRoute implements Route<RelationshipTarget> {
  RelatedRoute(this.target);

  @override
  final RelationshipTarget target;

  @override
  final allowedMethods = ['GET'];

  @override
  Future<Response> dispatch(HttpRequest request, Controller controller) {
    if (request.isGet) {
      return controller.fetchRelated(Request(request, this));
    }
    throw ArgumentError();
  }

  @override
  Uri self(UriFactory uriFactory) =>
      uriFactory.related(target.type, target.id, target.relationship);
}

class RelationshipRoute implements Route<RelationshipTarget> {
  RelationshipRoute(this.target);

  @override
  final RelationshipTarget target;

  @override
  final allowedMethods = ['DELETE', 'GET', 'PATCH', 'POST'];

  @override
  Future<Response> dispatch(HttpRequest request, Controller controller) {
    final r = Request(request, this);
    if (request.isDelete) {
      return controller.deleteFromRelationship(
          r, ToMany.fromJson(r.decodePayload()).unwrap());
    }
    if (request.isGet) {
      return controller.fetchRelationship(r);
    }
    if (request.isPatch) {
      final rel = Relationship.fromJson(r.decodePayload());
      if (rel is ToOne) {
        return controller.replaceToOne(r, rel.unwrap());
      }
      if (rel is ToMany) {
        return controller.replaceToMany(r, rel.unwrap());
      }
      throw IncompleteRelationshipException();
    }
    if (request.isPost) {
      return controller.addToRelationship(
          r, ToMany.fromJson(r.decodePayload()).unwrap());
    }
    throw ArgumentError();
  }

  @override
  Uri self(UriFactory uriFactory) =>
      uriFactory.relationship(target.type, target.id, target.relationship);
}

/// Thrown if the relationship object has no data
class IncompleteRelationshipException implements Exception {}
