import 'package:http_interop/http_interop.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';

abstract class BaseController() implements Controller {
  @override
  Future<Response> addMany(Request request, RelationshipTarget target) {
    throw UnimplementedError();
  }

  @override
  Future<Response> createResource(Request request, Target target) {
    throw UnimplementedError();
  }

  @override
  Future<Response> deleteMany(Request request, RelationshipTarget target) {
    throw UnimplementedError();
  }

  @override
  Future<Response> deleteResource(Request request, ResourceTarget target) {
    throw UnimplementedError();
  }

  @override
  Future<Response> fetchCollection(Request request, Target target) {
    throw UnimplementedError();
  }

  @override
  Future<Response> fetchRelated(Request request, RelatedTarget target) {
    throw UnimplementedError();
  }

  @override
  Future<Response> fetchRelationship(Request rq, RelationshipTarget target) {
    throw UnimplementedError();
  }

  @override
  Future<Response> fetchResource(Request request, ResourceTarget target) {
    throw UnimplementedError();
  }

  @override
  Future<Response> replaceRelationship(
    Request request,
    RelationshipTarget target,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Response> updateResource(Request request, ResourceTarget target) {
    throw UnimplementedError();
  }
}
