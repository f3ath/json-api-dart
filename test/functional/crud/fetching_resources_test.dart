import 'package:json_api/client.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/server/in_memory_repository.dart';
import 'package:json_api/src/server/json_api_server.dart';
import 'package:json_api/src/server/repository_controller.dart';
import 'package:json_api/uri_design.dart';
import 'package:test/test.dart';

import 'seed_resources.dart';

void main() async {
  SimpleClient client;
  JsonApiServer server;
  final host = 'localhost';
  final port = 80;
  final base = Uri(scheme: 'http', host: host, port: port);
  final design = UriDesign.standard(base);

  setUp(() async {
    final repository =
        InMemoryRepository({'books': {}, 'people': {}, 'companies': {}});
    server = JsonApiServer(design, RepositoryController(repository));
    client = SimpleClient(design, JsonApiClient(server));

    await seedResources(client);
  });

  group('Primary Resource', () {
    test('200 OK', () async {
      final r = await client.fetchResource('people', '1');
      expect(r.isSuccessful, isTrue);
      expect(r.statusCode, 200);
      expect(r.data.unwrap().id, '1');
      expect(r.data.unwrap().attributes['name'], 'Martin Fowler');
    });

    test('404 on collection', () async {
      final r = await client.fetchResource('unicorns', '1');
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.errors.first.status, '404');
      expect(r.errors.first.title, 'Collection not found');
      expect(r.errors.first.detail, "Collection 'unicorns' does not exist");
    });

    test('404 on resource', () async {
      final r = await client.fetchResource('people', '42');
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.errors.first.status, '404');
      expect(r.errors.first.title, 'Resource not found');
      expect(r.errors.first.detail, "Resource '42' does not exist in 'people'");
    });
  });

  group('Primary collections', () {
    test('200 OK', () async {
      final r = await client.fetchCollection('people');
      expect(r.isSuccessful, isTrue);
      expect(r.statusCode, 200);
      expect(r.data.unwrap().length, 3);
      expect(r.data.unwrap().first.attributes['name'], 'Martin Fowler');
    });

    test('404', () async {
      final r = await client.fetchCollection('unicorns');
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.errors.first.status, '404');
      expect(r.errors.first.title, 'Collection not found');
      expect(r.errors.first.detail, "Collection 'unicorns' does not exist");
    });
  });

  group('Related Resource', () {
    test('200 OK', () async {
      final r = await client.fetchRelatedResource('books', '1', 'publisher');
      expect(r.isSuccessful, isTrue);
      expect(r.statusCode, 200);
      expect(r.data.unwrap().type, 'companies');
      expect(r.data.unwrap().id, '1');
    });

    test('404 on collection', () async {
      final r = await client.fetchRelatedResource('unicorns', '1', 'publisher');
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.errors.first.status, '404');
      expect(r.errors.first.title, 'Collection not found');
      expect(r.errors.first.detail, "Collection 'unicorns' does not exist");
    });

    test('404 on resource', () async {
      final r = await client.fetchRelatedResource('books', '42', 'publisher');
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.errors.first.status, '404');
      expect(r.errors.first.title, 'Resource not found');
      expect(r.errors.first.detail, "Resource '42' does not exist in 'books'");
    });

    test('404 on relationship', () async {
      final r = await client.fetchRelatedResource('books', '1', 'owner');
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.errors.first.status, '404');
      expect(r.errors.first.title, 'Relationship not found');
      expect(r.errors.first.detail,
          "Relationship 'owner' does not exist in 'books:1'");
    });
  });

  group('Related Collection', () {
    test('successful', () async {
      final r = await client.fetchRelatedCollection('books', '1', 'authors');
      expect(r.isSuccessful, isTrue);
      expect(r.statusCode, 200);
      expect(r.data.unwrap().length, 2);
      expect(r.data.unwrap().first.attributes['name'], 'Martin Fowler');
    });

    test('404 on collection', () async {
      final r = await client.fetchRelatedCollection('unicorns', '1', 'athors');
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.errors.first.status, '404');
      expect(r.errors.first.title, 'Collection not found');
      expect(r.errors.first.detail, "Collection 'unicorns' does not exist");
    });

    test('404 on resource', () async {
      final r = await client.fetchRelatedCollection('books', '42', 'authors');
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.errors.first.status, '404');
      expect(r.errors.first.title, 'Resource not found');
      expect(r.errors.first.detail, "Resource '42' does not exist in 'books'");
    });

    test('404 on relationship', () async {
      final r = await client.fetchRelatedCollection('books', '1', 'readers');
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.errors.first.status, '404');
      expect(r.errors.first.title, 'Relationship not found');
      expect(r.errors.first.detail,
          "Relationship 'readers' does not exist in 'books:1'");
    });
  });
}
