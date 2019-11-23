import 'dart:async';

import 'package:json_api/query.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/http_method.dart';
import 'package:json_api/src/server/response/response.dart';
import 'package:json_api/src/server/routing/route.dart';
import 'package:json_api/url_design.dart';

class RelatedRoute implements Route {
  final RelationshipTarget target;

  RelatedRoute(this.target);

  @override
  FutureOr<Response> call(
      Controller controller, Query query, HttpMethod method, Object body) {
    if (method.isGet()) return controller.fetchRelated(target, query);
    return null;
  }
}
