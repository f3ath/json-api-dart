import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/server/method_not_allowed.dart';

class Router {
  const Router(this.matcher);

  final TargetMatcher matcher;

  T route<T>(HttpRequest rq, JsonApiController<T> controller) {
    final target = matcher.match(rq.uri);
    if (target is CollectionTarget) {
      if (rq.isGet) return controller.fetchCollection(rq, target);
      if (rq.isPost) return controller.createResource(rq, target);
      throw MethodNotAllowed(rq.method);
    }
    if (target is ResourceTarget) {
      if (rq.isGet) return controller.fetchResource(rq, target);
      if (rq.isDelete) return controller.deleteResource(rq, target);
      if (rq.isPatch) return controller.updateResource(rq, target);
      throw MethodNotAllowed(rq.method);
    }
    if (target is RelationshipTarget) {
      if (rq.isGet) return controller.fetchRelationship(rq, target);
      if (rq.isPost) return controller.addMany(rq, target);
      if (rq.isPatch) return controller.replaceRelationship(rq, target);
      if (rq.isDelete) return controller.deleteMany(rq, target);
      throw MethodNotAllowed(rq.method);
    }
    throw 'UnmatchedTarget $target';
  }
}
