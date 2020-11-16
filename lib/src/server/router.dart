import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/server/method_not_allowed.dart';

class Router {
  const Router(this.matcher);

  final TargetMatcher matcher;

  T route<T>(HttpRequest request, JsonApiController<T> controller) {
    final target = matcher.match(request.uri);
    if (target is CollectionTarget) {
      if (request.isGet) return controller.fetchCollection(request, target);
      if (request.isPost) return controller.createResource(request, target);
      throw MethodNotAllowed(request.method);
    }
    if (target is ResourceTarget) {
      if (request.isGet) return controller.fetchResource(request, target);
      throw MethodNotAllowed(request.method);
    }
    throw 'UnmatchedTarget';
  }
}
