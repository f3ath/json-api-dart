import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/query.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/http_method.dart';
import 'package:json_api/src/server/response/response.dart';
import 'package:json_api/src/server/routing/route.dart';

class ResourceRoute implements Route {
  final String type;
  final String id;

  ResourceRoute(this.type, this.id);

  @override
  FutureOr<Response> call(
      Controller controller, Query query, HttpMethod method, Object body) {
    if (method.isGet()) {
      return controller.fetchResource(type, id, query);
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
