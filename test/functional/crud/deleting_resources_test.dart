import 'package:json_api/client.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/server/in_memory_repository.dart';
import 'package:json_api/src/server/json_api_server.dart';
import 'package:json_api/src/server/repository_controller.dart';
import 'package:json_api/uri_design.dart';
import 'package:test/test.dart';

import 'seed_resources.dart';

void main() async {
  JsonApiClient client;
  JsonApiServer server;
  final host = 'localhost';
  final port = 80;
  final base = Uri(scheme: 'http', host: host, port: port);
  final design = UriDesign.standard(base);

  setUp(() async {
    final repository =
        InMemoryRepository({'books': {}, 'people': {}, 'companies': {}});
    server = JsonApiServer(design, RepositoryController(repository));
    client = JsonApiClient(server, uriFactory: design);

    await seedResources(client);
  });

  test('successful', () async {
    final r = await client.deleteResource('books', '1');
    expect(r.isSuccessful, isTrue);
    expect(r.statusCode, 204);
    expect(r.data, isNull);

    final r1 = await client.fetchResource('books', '1');
    expect(r1.isSuccessful, isFalse);
    expect(r1.statusCode, 404);
  });

  test('404 on collecton', () async {
    final r = await client.deleteResource('unicorns', '42');
    expect(r.isSuccessful, isFalse);
    expect(r.isFailed, isTrue);
    expect(r.statusCode, 404);
    expect(r.data, isNull);
    final error = r.errors.first;
    expect(error.status, '404');
    expect(error.title, 'Collection not found');
    expect(error.detail, "Collection 'unicorns' does not exist");
  });

  test('404 on resource', () async {
    final r = await client.deleteResource('books', '42');
    expect(r.isSuccessful, isFalse);
    expect(r.isFailed, isTrue);
    expect(r.statusCode, 404);
    expect(r.data, isNull);
    final error = r.errors.first;
    expect(error.status, '404');
    expect(error.title, 'Resource not found');
    expect(error.detail, "Resource '42' does not exist in 'books'");
  });
}
