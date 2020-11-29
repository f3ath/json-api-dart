import 'package:json_api/handler.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/method_not_allowed.dart';
import 'package:json_api/src/server/unmatched_target.dart';

class Router<R> implements Handler<HttpRequest, R> {
  Router(this.controller, this.matchTarget);

  final Controller<R> controller;
  final Target? Function(Uri uri) matchTarget;

  @override
  Future<R> call(HttpRequest request) async {
    final target = matchTarget(request.uri);
    if (target is CollectionTarget) {
      if (request.isGet) {
        return await controller.fetchCollection(request, target);
      }
      if (request.isPost) {
        return await controller.createResource(request, target);
      }
      throw MethodNotAllowed(request.method);
    }
    if (target is ResourceTarget) {
      if (request.isGet) {
        return await controller.fetchResource(request, target);
      }
      if (request.isPatch) {
        return await controller.updateResource(request, target);
      }
      if (request.isDelete) {
        return await controller.deleteResource(request, target);
      }
      throw MethodNotAllowed(request.method);
    }
    if (target is RelationshipTarget) {
      if (request.isGet) {
        return await controller.fetchRelationship(request, target);
      }
      if (request.isPost) return await controller.addMany(request, target);
      if (request.isPatch) {
        return await controller.replaceRelationship(request, target);
      }
      if (request.isDelete) {
        return await controller.deleteMany(request, target);
      }
      throw MethodNotAllowed(request.method);
    }
    if (target is RelatedTarget) {
      if (request.isGet) {
        return await controller.fetchRelated(request, target);
      }
      throw MethodNotAllowed(request.method);
    }
    throw UnmatchedTarget(request.uri);
  }
}
