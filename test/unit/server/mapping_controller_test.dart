import 'package:http_interop/http_interop.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';
import 'package:test/test.dart';

void main() {
  group('MappingController', () {
    final request = Request('get', Uri(), Body(), Headers());
    const target = Target('articles');
    const resourceTarget = ResourceTarget('articles', '1');
    const relationshipTarget = RelationshipTarget('articles', '1', 'author');
    const relatedTarget = RelatedTarget('articles', '1', 'author');

    late MappingController controller;
    late _Controller articles;

    setUp(() {
      controller = MappingController();
      articles = _Controller();
      controller.map['articles'] = articles;
    });

    test('delegates to the controller mapped to the target type', () async {
      await controller.addMany(request, relationshipTarget);
      await controller.createResource(request, target);
      await controller.deleteMany(request, relationshipTarget);
      await controller.deleteResource(request, resourceTarget);
      await controller.fetchCollection(request, target);
      await controller.fetchRelated(request, relatedTarget);
      await controller.fetchRelationship(request, relationshipTarget);
      await controller.fetchResource(request, resourceTarget);
      await controller.replaceRelationship(request, relationshipTarget);
      await controller.updateResource(request, resourceTarget);

      expect(articles.calls, [
        'addMany',
        'createResource',
        'deleteMany',
        'deleteResource',
        'fetchCollection',
        'fetchRelated',
        'fetchRelationship',
        'fetchResource',
        'replaceRelationship',
        'updateResource',
      ]);
    });

    test('throws CollectionNotFound when target type is not mapped', () {
      expect(
        () => controller.fetchCollection(request, const Target('people')),
        throwsA(isA<CollectionNotFound>()),
      );
    });
  });
}

final class _Controller implements Controller {
  final calls = <String>[];

  @override
  Future<Response> addMany(Request request, RelationshipTarget target) =>
      _call('addMany');

  @override
  Future<Response> createResource(Request request, Target target) =>
      _call('createResource');

  @override
  Future<Response> deleteMany(Request request, RelationshipTarget target) =>
      _call('deleteMany');

  @override
  Future<Response> deleteResource(Request request, ResourceTarget target) =>
      _call('deleteResource');

  @override
  Future<Response> fetchCollection(Request request, Target target) =>
      _call('fetchCollection');

  @override
  Future<Response> fetchRelated(Request request, RelatedTarget target) =>
      _call('fetchRelated');

  @override
  Future<Response> fetchRelationship(Request rq, RelationshipTarget target) =>
      _call('fetchRelationship');

  @override
  Future<Response> fetchResource(Request request, ResourceTarget target) =>
      _call('fetchResource');

  @override
  Future<Response> replaceRelationship(
    Request request,
    RelationshipTarget target,
  ) => _call('replaceRelationship');

  @override
  Future<Response> updateResource(Request request, ResourceTarget target) =>
      _call('updateResource');

  Future<Response> _call(String name) async {
    calls.add(name);
    return Response(200, Body(), Headers());
  }
}
