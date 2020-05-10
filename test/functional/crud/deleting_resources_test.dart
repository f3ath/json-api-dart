import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
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
  final routing = StandardRouting(base);

  setUp(() async {
    final repository =
        InMemoryRepository({'books': {}, 'people': {}, 'companies': {}});
    server = JsonApiServer(RepositoryController(repository));
    client = JsonApiClient(server, routing);

    await seedResources(client);
  });

  test('successful', () async {
    final r = await client.deleteResource('books', '1');
    expect(r.isSuccessful, isTrue);
    expect(r.http.statusCode, 204);
    try {
      await client.fetchResource('books', '1');
      fail('Exception expected');
    } on RequestFailure catch (e) {
      expect(e.http.statusCode, 404);
      expect(e.http.headers['content-type'], Document.contentType);
    }
  });

  test('404 on collection', () async {
    try {
      await client.deleteResource('unicorns', '42');
      fail('Exception expected');
    } on RequestFailure catch (e) {
      expect(e.http.statusCode, 404);
      expect(e.http.headers['content-type'], Document.contentType);
      expect(e.errors.first.status, '404');
      expect(e.errors.first.title, 'Collection not found');
      expect(e.errors.first.detail, "Collection 'unicorns' does not exist");
    }
  });

  test('404 on resource', () async {
    try {
      await client.deleteResource('books', '42');
      fail('Exception expected');
    } on RequestFailure catch (e) {
      expect(e.http.statusCode, 404);
      expect(e.http.headers['content-type'], Document.contentType);
      expect(e.errors.first.status, '404');
      expect(e.errors.first.title, 'Resource not found');
      expect(e.errors.first.detail, "Resource '42' does not exist in 'books'");
    }
  });
}
