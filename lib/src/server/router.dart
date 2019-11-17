import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/src/query/query.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/response.dart';
import 'package:json_api/src/target.dart';
import 'package:json_api/url_design.dart';

class Router {
  final TargetMatcher matcher;

  Router(this.matcher);

  Route getRoute(Uri uri) {
    Route route = InvalidRoute();
    matcher.match(
      uri,
      onCollection: (type) => route = CollectionRoute(CollectionTarget(type)),
      onResource: (type, id) => route = ResourceRoute(ResourceTarget(type, id)),
      onRelationship: (type, id, relationship) =>
          route = RelationshipRoute(RelationshipTarget(type, id, relationship)),
      onRelated: (type, id, relationship) =>
          route = RelatedRoute(RelationshipTarget(type, id, relationship)),
    );
    return route;
  }
}

abstract class Route {
  FutureOr<Response> call(
      Controller controller, Query query, Method method, Object body);
}

class CollectionRoute extends Route {
  final CollectionTarget target;

  CollectionRoute(this.target);

  @override
  FutureOr<Response> call(
      Controller controller, Query query, Method method, Object body) {
    if (method.isGet()) {
      return controller.fetchCollection(target, query);
    }
    if (method.isPost()) {
      return controller.createResource(target,
          Document.fromJson(body, ResourceData.fromJson).data.unwrap());
    }
    return null;
  }
}

class ResourceRoute extends Route {
  final ResourceTarget target;

  ResourceRoute(this.target);

  @override
  FutureOr<Response> call(
      Controller controller, Query query, Method method, Object body) {
    if (method.isGet()) {
      return controller.fetchResource(target, query);
    }
    if (method.isDelete()) {
      return controller.deleteResource(target);
    }
    if (method.isPatch()) {
      return controller.updateResource(target,
          Document.fromJson(body, ResourceData.fromJson).data.unwrap());
    }
    return null;
  }
}

class RelationshipRoute extends Route {
  final RelationshipTarget target;

  RelationshipRoute(this.target);

  @override
  FutureOr<Response> call(
      Controller controller, Query query, Method method, Object body) {
    if (method.isGet()) {
      return controller.fetchRelationship(target, query);
    }
    if (method.isPatch()) {
      final rel = Relationship.fromJson(body);
      if (rel is ToOne) {
        return controller.replaceToOne(target, rel.unwrap());
      }
      if (rel is ToMany) {
        return controller.replaceToMany(target, rel.identifiers);
      }
    }
    if (method.isPost()) {
      final rel = Relationship.fromJson(body);
      if (rel is ToMany) {
        return controller.addToMany(target, rel.identifiers);
      }
    }
    return null;
  }
}

class RelatedRoute extends Route {
  final RelationshipTarget target;

  RelatedRoute(this.target);

  @override
  FutureOr<Response> call(
      Controller controller, Query query, Method method, Object body) {
    if (method.isGet()) return controller.fetchRelated(target, query);
    return null;
  }
}

class InvalidRoute extends Route {
  InvalidRoute();

  @override
  Future<Response> call(
          Controller controller, Query query, Method method, Object body) =>
      null;
}

class Method {
  final String _name;

  Method(String name) : this._name = name.toUpperCase();

  bool isPost() => _name == 'POST';

  bool isGet() => _name == 'GET';

  bool isPatch() => _name == 'PATCH';

  bool isDelete() => _name == 'DELETE';
}
