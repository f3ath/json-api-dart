import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/query.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/http_method.dart';
import 'package:json_api/src/server/response/response.dart';

abstract class Route {
  FutureOr<Response> call(
      Controller controller, Query query, HttpMethod method, Object body);
}

class InvalidRoute implements Route {
  InvalidRoute();

  @override
  Future<Response> call(
          Controller controller, Query query, HttpMethod method, Object body) =>
      null;
}

class CollectionRoute implements Route {
  final String type;

  CollectionRoute(this.type);

  @override
  FutureOr<Response> call(
      Controller controller, Query query, HttpMethod method, Object body) {
    if (method.isGet()) {
      return controller.fetchCollection(type, query);
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
  FutureOr<Response> call(
      Controller controller, Query query, HttpMethod method, Object body) {
    if (method.isGet())
      return controller.fetchRelated(type, id, relationship, query);
    return null;
  }
}

class RelationshipRoute implements Route {
  final String type;
  final String id;
  final String relationship;

  RelationshipRoute(this.type, this.id, this.relationship);

  @override
  FutureOr<Response> call(
      Controller controller, Query query, HttpMethod method, Object body) {
    if (method.isGet()) {
      return controller.fetchRelationship(type, id, relationship, query);
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
