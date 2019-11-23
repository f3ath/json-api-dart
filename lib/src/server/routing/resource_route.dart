import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/query.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/http_method.dart';
import 'package:json_api/src/server/response/response.dart';
import 'package:json_api/src/server/routing/route.dart';
import 'package:json_api/url_design.dart';

class ResourceRoute implements Route {
  final ResourceTarget target;

  ResourceRoute(this.target);

  @override
  FutureOr<Response> call(
      Controller controller, Query query, HttpMethod method, Object body) {
    if (method.isGet()) {
      return controller.fetchResource(target, query);
    }
    if (method.isDelete()) {
      return controller.deleteResource(target);
    }
    if (method.isPatch()) {
      return controller.updateResource(
          target, Document.fromJson(body, ResourceData.fromJson).data.unwrap());
    }
    return null;
  }
}
