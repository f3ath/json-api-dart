import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/query.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/http_method.dart';
import 'package:json_api/src/server/response/response.dart';
import 'package:json_api/src/server/routing/route.dart';
import 'package:json_api/url_design.dart';

class RelationshipRoute implements Route {
  final RelationshipTarget target;

  RelationshipRoute(this.target);

  @override
  FutureOr<Response> call(
      Controller controller, Query query, HttpMethod method, Object body) {
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
