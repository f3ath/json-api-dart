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
    expect(r.isEmpty, isTrue);
    expect(r.http.statusCode, 204);

    final r1 = await client.fetchResource('books', '1');
    expect(r1.isSuccessful, isFalse);
    expect(r1.http.statusCode, 404);
    expect(r1.http.headers['content-type'], Document.contentType);
  });

  test('404 on collection', () async {
    final r = await client.deleteResource('unicorns', '42');
    expect(r.isSuccessful, isFalse);
    expect(r.isFailed, isTrue);
    expect(r.http.statusCode, 404);
    expect(r.http.headers['content-type'], Document.contentType);
    expect(r.decodeDocument().data, isNull);
    final error = r.decodeDocument().errors.first;
    expect(error.status, '404');
    expect(error.title, 'Collection not found');
    expect(error.detail, "Collection 'unicorns' does not exist");
  });

  test('404 on resource', () async {
    final r = await client.deleteResource('books', '42');
    expect(r.isSuccessful, isFalse);
    expect(r.isFailed, isTrue);
    expect(r.http.statusCode, 404);
    expect(r.http.headers['content-type'], Document.contentType);
    expect(r.decodeDocument().data, isNull);
    final error = r.decodeDocument().errors.first;
    expect(error.status, '404');
    expect(error.title, 'Resource not found');
    expect(error.detail, "Resource '42' does not exist in 'books'");
  });
}
