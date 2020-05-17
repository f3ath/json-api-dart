import 'package:json_api/client.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/server/in_memory_repository.dart';
import 'package:json_api/src/server/json_api_server.dart';
import 'package:json_api/src/server/repository_controller.dart';
import 'package:test/test.dart';

import 'seed_resources.dart';

void main() async {
  JsonApiServer server;
  JsonApiClient client;
  final host = 'localhost';
  final port = 80;
  final base = Uri(scheme: 'http', host: host, port: port);
  final urls = StandardRouting(base);

  setUp(() async {
    final repository =
        InMemoryRepository({'books': {}, 'people': {}, 'companies': {}});
    server = JsonApiServer(RepositoryController(repository));
    client = JsonApiClient(server, urls);

    await seedResources(client);
  });

  test('200 OK', () async {
    final r = await client.updateResource('books', '1', attributes: {
      'title': 'Refactoring. Improving the Design of Existing Code',
      'pages': 448
    }, one: {
      'publisher': null,
    }, many: {
      'authors': ['people:1'],
      'reviewers': ['people:2']
    });
    expect(r.http.statusCode, 200);
    expect(r.http.headers['content-type'], ContentType.jsonApi);
    expect(r.resource().attributes['title'],
        'Refactoring. Improving the Design of Existing Code');
    expect(r.resource().attributes['pages'], 448);
    expect(r.resource().attributes['ISBN-10'], '0134757599');
    expect(r.resource().one('publisher').isEmpty, true);
    expect(r.resource().many('authors').toList().first.key, equals('people:1'));
    expect(
        r.resource().many('reviewers').toList().first.key, equals('people:2'));

    final r1 = await client.fetchResource('books', '1');
    expect(r1.resource.attributes, r.resource().attributes);
  });

  test('204 No Content', () async {
    final r = await client.updateResource('books', '1');
    expect(r.http.statusCode, 204);
  });

  test('404 on the target resource', () async {
    try {
      await client.updateResource('books', '42');
      fail('Exception expected');
    } on RequestFailure catch (e) {
      expect(e.http.statusCode, 404);
      expect(e.http.headers['content-type'], ContentType.jsonApi);
      expect(e.errors.first.status, '404');
      expect(e.errors.first.title, 'Resource not found');
      expect(e.errors.first.detail, "Resource '42' does not exist in 'books'");
    }
  });
//
//  test('409 when the resource type does not match the collection', () async {
//    final r = await client.send(
//        Request.updateResource(
//            Document(ResourceData.fromResource(Resource('books', '1')))),
//        urls.resource('people', '1'));
//    expect(r.isSuccessful, isFalse);
//    expect(r.http.statusCode, 409);
//    expect(r.http.headers['content-type'], ContentType.jsonApi);
//    expect(r.decodeDocument().data, isNull);
//    final error = r.decodeDocument().errors.first;
//    expect(error.status, '409');
//    expect(error.title, 'Invalid resource type');
//    expect(error.detail, "Type 'books' does not belong in 'people'");
//  });
}
