import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/server/_internal/in_memory_repo.dart';
import 'package:json_api/src/server/_internal/repository_controller.dart';
import 'package:test/test.dart';

import '../../src/sequential_numbers.dart';

void main() {
  final controller = RepositoryController(InMemoryRepo([]), sequentialNumbers);
  test('Incomplete relationship', () async {
    try {
      await controller.replaceRelationship(
          HttpRequest('patch', Uri(), body: '{}'),
          RelationshipTarget('posts', '1', 'author'));
      fail('Exception expected');
    } on FormatException catch (e) {
      expect(e.message, 'Incomplete relationship');
    }
  });
}
