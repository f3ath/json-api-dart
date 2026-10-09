import 'package:http_interop/http_interop.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';

/// A controller that delegates requests to other controllers based on the
/// resource type.
class MappingController() implements Controller {
  final map = <String, Controller>{};

  @override
  Future<Response> addMany(Request request, RelationshipTarget target) =>
      _controller(target.type).addMany(request, target);

  @override
  Future<Response> createResource(Request request, Target target) =>
      _controller(target.type).createResource(request, target);

  @override
  Future<Response> deleteMany(Request request, RelationshipTarget target) =>
      _controller(target.type).deleteMany(request, target);

  @override
  Future<Response> deleteResource(Request request, ResourceTarget target) =>
      _controller(target.type).deleteResource(request, target);

  @override
  Future<Response> fetchCollection(Request request, Target target) =>
      _controller(target.type).fetchCollection(request, target);

  @override
  Future<Response> fetchRelated(Request request, RelatedTarget target) =>
      _controller(target.type).fetchRelated(request, target);

  @override
  Future<Response> fetchRelationship(Request rq, RelationshipTarget target) =>
      _controller(target.type).fetchRelationship(rq, target);

  @override
  Future<Response> fetchResource(Request request, ResourceTarget target) =>
      _controller(target.type).fetchResource(request, target);

  @override
  Future<Response> replaceRelationship(
    Request request,
    RelationshipTarget target,
  ) => _controller(target.type).replaceRelationship(request, target);

  @override
  Future<Response> updateResource(Request request, ResourceTarget target) =>
      _controller(target.type).updateResource(request, target);

  Controller _controller(String type) =>
      map[type] ?? (throw CollectionNotFound(type));
}
