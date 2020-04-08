import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/server/request.dart';
import 'package:json_api/src/server/resolvable_request.dart';
import 'package:json_api/src/server/target.dart';

abstract class Route {
  List<String> get allowedMethods;

  ResolvableRequest convertRequest(HttpRequest request);
}

class RouteFactory implements UriMatchHandler {
  Route route;

  @override
  void collection(String type) {
    route = CollectionRoute(type);
  }

  @override
  void related(String type, String id, String relationship) {
    route = RelatedRoute(type, id, relationship);
  }

  @override
  void relationship(String type, String id, String relationship) {
    route = RelationshipRoute(type, id, relationship);
  }

  @override
  void resource(String type, String id) {
    route = ResourceRoute(type, id);
  }
}

class CollectionRoute implements Route, CollectionTarget {
  CollectionRoute(this.type);

  @override
  final String type;

  @override
  final allowedMethods = ['GET', 'POST'];

  @override
  ResolvableRequest convertRequest(HttpRequest request) {
    final r = CollectionRequest(request, this);
    if (request.isGet) {
      return FetchCollection(r);
    }
    if (request.isPost) {
      return CreateResource(r);
    }
    throw ArgumentError();
  }
}

class ResourceRoute implements Route, ResourceTarget {
  ResourceRoute(this.type, this.id);

  @override
  final String type;
  @override
  final String id;

  @override
  final allowedMethods = ['DELETE', 'GET', 'PATCH'];

  @override
  ResolvableRequest convertRequest(HttpRequest request) {
    final r = ResourceRequest(request, this);
    if (request.isDelete) {
      return DeleteResource(r);
    }
    if (request.isGet) {
      return FetchResource(r);
    }
    if (request.isPatch) {
      return UpdateResource(r);
    }
    throw ArgumentError();
  }
}

class RelatedRoute implements Route, RelationshipTarget {
  RelatedRoute(this.type, this.id, this.relationship);

  @override
  final String type;
  @override
  final String id;
  @override
  final String relationship;

  @override
  final allowedMethods = ['GET'];

  @override
  ResolvableRequest convertRequest(HttpRequest request) {
    if (request.isGet) {
      return FetchRelated(RelatedRequest(request, this));
    }
    throw ArgumentError();
  }
}

class RelationshipRoute implements Route, RelationshipTarget {
  RelationshipRoute(this.type, this.id, this.relationship);

  @override
  final String type;
  @override
  final String id;
  @override
  final String relationship;

  @override
  final allowedMethods = ['DELETE', 'GET', 'PATCH', 'POST'];

  @override
  ResolvableRequest convertRequest(HttpRequest request) {
    final r = RelationshipRequest(request, this);
    if (request.isDelete) {
      return DeleteFromRelationship(r);
    }
    if (request.isGet) {
      return FetchRelationship(r);
    }
    if (request.isPatch) {
      return ReplaceRelationship(r);
    }
    if (request.isPost) {
      return AddToRelationship(r);
    }
    throw ArgumentError();
  }
}
