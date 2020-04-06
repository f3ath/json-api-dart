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

  group('Primary Resource', () {
    test('200 OK', () async {
      final r = await routingClient.fetchResource('people', '1');
      expect(r.isSuccessful, isTrue);
      expect(r.statusCode, 200);
      expect(r.headers['content-type'], Document.contentType);
      expect(r.data.unwrap().id, '1');
      expect(r.data.unwrap().attributes['name'], 'Martin Fowler');
    });

    test('404 on collection', () async {
      final r = await routingClient.fetchResource('unicorns', '1');
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.headers['content-type'], Document.contentType);
      expect(r.errors.first.status, '404');
      expect(r.errors.first.title, 'Collection not found');
      expect(r.errors.first.detail, "Collection 'unicorns' does not exist");
    });

    test('404 on resource', () async {
      final r = await routingClient.fetchResource('people', '42');
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.headers['content-type'], Document.contentType);
      expect(r.errors.first.status, '404');
      expect(r.errors.first.title, 'Resource not found');
      expect(r.errors.first.detail, "Resource '42' does not exist in 'people'");
    });
  });

  group('Primary collections', () {
    test('200 OK', () async {
      final r = await routingClient.fetchCollection('people');
      expect(r.isSuccessful, isTrue);
      expect(r.statusCode, 200);
      expect(r.headers['content-type'], Document.contentType);
      expect(r.data.unwrap().length, 3);
      expect(r.data.unwrap().first.attributes['name'], 'Martin Fowler');
    });

    test('404', () async {
      final r = await routingClient.fetchCollection('unicorns');
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.headers['content-type'], Document.contentType);
      expect(r.errors.first.status, '404');
      expect(r.errors.first.title, 'Collection not found');
      expect(r.errors.first.detail, "Collection 'unicorns' does not exist");
    });
  });

  group('Related Resource', () {
    test('200 OK', () async {
      final r =
          await routingClient.fetchRelatedResource('books', '1', 'publisher');
      expect(r.isSuccessful, isTrue);
      expect(r.statusCode, 200);
      expect(r.headers['content-type'], Document.contentType);
      expect(r.data.unwrap().type, 'companies');
      expect(r.data.unwrap().id, '1');
    });

    test('404 on collection', () async {
      final r = await routingClient.fetchRelatedResource(
          'unicorns', '1', 'publisher');
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.headers['content-type'], Document.contentType);
      expect(r.errors.first.status, '404');
      expect(r.errors.first.title, 'Collection not found');
      expect(r.errors.first.detail, "Collection 'unicorns' does not exist");
    });

    test('404 on resource', () async {
      final r =
          await routingClient.fetchRelatedResource('books', '42', 'publisher');
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.headers['content-type'], Document.contentType);
      expect(r.errors.first.status, '404');
      expect(r.errors.first.title, 'Resource not found');
      expect(r.errors.first.detail, "Resource '42' does not exist in 'books'");
    });

    test('404 on relationship', () async {
      final r = await routingClient.fetchRelatedResource('books', '1', 'owner');
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.headers['content-type'], Document.contentType);
      expect(r.errors.first.status, '404');
      expect(r.errors.first.title, 'Relationship not found');
      expect(r.errors.first.detail,
          "Relationship 'owner' does not exist in this resource");
    });
  });

  group('Related Collection', () {
    test('successful', () async {
      final r =
          await routingClient.fetchRelatedCollection('books', '1', 'authors');
      expect(r.isSuccessful, isTrue);
      expect(r.statusCode, 200);
      expect(r.headers['content-type'], Document.contentType);
      expect(r.data.unwrap().length, 2);
      expect(r.data.unwrap().first.attributes['name'], 'Martin Fowler');
    });

    test('404 on collection', () async {
      final r =
          await routingClient.fetchRelatedCollection('unicorns', '1', 'athors');
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.headers['content-type'], Document.contentType);
      expect(r.errors.first.status, '404');
      expect(r.errors.first.title, 'Collection not found');
      expect(r.errors.first.detail, "Collection 'unicorns' does not exist");
    });

    test('404 on resource', () async {
      final r =
          await routingClient.fetchRelatedCollection('books', '42', 'authors');
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.headers['content-type'], Document.contentType);
      expect(r.errors.first.status, '404');
      expect(r.errors.first.title, 'Resource not found');
      expect(r.errors.first.detail, "Resource '42' does not exist in 'books'");
    });

    test('404 on relationship', () async {
      final r =
          await routingClient.fetchRelatedCollection('books', '1', 'readers');
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.headers['content-type'], Document.contentType);
      expect(r.errors.first.status, '404');
      expect(r.errors.first.title, 'Relationship not found');
      expect(r.errors.first.detail,
          "Relationship 'readers' does not exist in this resource");
    });
  });
}
