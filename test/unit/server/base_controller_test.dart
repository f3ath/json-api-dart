import 'package:http_interop/http_interop.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';
import 'package:test/test.dart';

void main() {
  group('BaseController', () {
    final controller = _Controller();
    final request = Request('get', Uri(), Body(), Headers());
    const target = CollectionTarget('articles');
    const resourceTarget = ResourceTarget('articles', '1');
    const relationshipTarget = RelationshipTarget('articles', '1', 'author');
    const relatedTarget = RelatedTarget('articles', '1', 'author');

    test('throws UnimplementedError from default handlers', () {
      final handlers = <void Function()>[
        () => controller.addMany(request, relationshipTarget),
        () => controller.createResource(request, target),
        () => controller.deleteMany(request, relationshipTarget),
        () => controller.deleteResource(request, resourceTarget),
        () => controller.fetchCollection(request, target),
        () => controller.fetchRelated(request, relatedTarget),
        () => controller.fetchRelationship(request, relationshipTarget),
        () => controller.fetchResource(request, resourceTarget),
        () => controller.replaceRelationship(request, relationshipTarget),
        () => controller.updateResource(request, resourceTarget),
      ];

      for (final handler in handlers) {
        expect(handler, throwsUnimplementedError);
      }
    });
  });
}

final class _Controller() extends BaseController {}
