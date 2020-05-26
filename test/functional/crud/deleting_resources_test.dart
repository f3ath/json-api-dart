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
  RoutingClient routingClient;
  final host = 'localhost';
  final port = 80;
  final base = Uri(scheme: 'http', host: host, port: port);
  final routing = StandardRouting(base);

  setUp(() async {
    final repository =
        InMemoryRepository({'books': {}, 'people': {}, 'companies': {}});
    server = JsonApiServer(RepositoryController(repository));
    client = JsonApiClient(server);
    routingClient = RoutingClient(client, routing);

    await seedResources(routingClient);
  });

  test('successful', () async {
    final r = await routingClient.deleteResource('books', '1');
    expect(r.isSuccessful, isTrue);
    expect(r.statusCode, 204);
    expect(r.data, isNull);

    final r1 = await routingClient.fetchResource('books', '1');
    expect(r1.isSuccessful, isFalse);
    expect(r1.statusCode, 404);
  });

  test('404 on collecton', () async {
    final r = await routingClient.deleteResource('unicorns', '42');
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
    final r = await routingClient.deleteResource('books', '42');
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
