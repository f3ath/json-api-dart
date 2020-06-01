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

  group('Updatng a to-one relationship', () {
    test('204 No Content', () async {
      final r = await routingClient.replaceToOne(
          'books', '1', 'publisher', Identifier('companies', '2'));
      expect(r.isSuccessful, isTrue);
      expect(r.statusCode, 204);
      expect(r.data, isNull);

      final r1 = await routingClient.fetchResource('books', '1');
      expect(r1.data.unwrap().toOne['publisher'].id, '2');
    });

    test('404 on collection', () async {
      final r = await routingClient.replaceToOne(
          'unicorns', '1', 'breed', Identifier('companies', '2'));
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.data, isNull);
      final error = r.errors.first;
      expect(error.status, '404');
      expect(error.title, 'Collection not found');
      expect(error.detail, "Collection 'unicorns' does not exist");
    });

    test('404 on resource', () async {
      final r = await routingClient.replaceToOne(
          'books', '42', 'publisher', Identifier('companies', '2'));
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.data, isNull);
      final error = r.errors.first;
      expect(error.status, '404');
      expect(error.title, 'Resource not found');
      expect(error.detail, "Resource '42' does not exist in 'books'");
    });
  });

  group('Deleting a to-one relationship', () {
    test('204 No Content', () async {
      final r = await routingClient.deleteToOne('books', '1', 'publisher');
      expect(r.isSuccessful, isTrue);
      expect(r.statusCode, 204);
      expect(r.data, isNull);

      final r1 = await routingClient.fetchResource('books', '1');
      expect(r1.data.unwrap().toOne['publisher'], isNull);
    });

    test('404 on collection', () async {
      final r = await routingClient.deleteToOne('unicorns', '1', 'breed');
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.data, isNull);
      final error = r.errors.first;
      expect(error.status, '404');
      expect(error.title, 'Collection not found');
      expect(error.detail, "Collection 'unicorns' does not exist");
    });

    test('404 on resource', () async {
      final r = await routingClient.deleteToOne('books', '42', 'publisher');
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.data, isNull);
      final error = r.errors.first;
      expect(error.status, '404');
      expect(error.title, 'Resource not found');
      expect(error.detail, "Resource '42' does not exist in 'books'");
    });
  });

  group('Replacing a to-many relationship', () {
    test('204 No Content', () async {
      final r = await routingClient
          .replaceToMany('books', '1', 'authors', [Identifier('people', '1')]);
      expect(r.isSuccessful, isTrue);
      expect(r.statusCode, 204);
      expect(r.data, isNull);

      final r1 = await routingClient.fetchResource('books', '1');
      expect(r1.data.unwrap().toMany['authors'].length, 1);
      expect(r1.data.unwrap().toMany['authors'].first.id, '1');
    });

    test('404 when collection not found', () async {
      final r = await routingClient.replaceToMany(
          'unicorns', '1', 'breed', [Identifier('companies', '2')]);
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.data, isNull);
      final error = r.errors.first;
      expect(error.status, '404');
      expect(error.title, 'Collection not found');
      expect(error.detail, "Collection 'unicorns' does not exist");
    });

    test('404 when resource not found', () async {
      final r = await routingClient.replaceToMany(
          'books', '42', 'publisher', [Identifier('companies', '2')]);
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.data, isNull);
      final error = r.errors.first;
      expect(error.status, '404');
      expect(error.title, 'Resource not found');
      expect(error.detail, "Resource '42' does not exist in 'books'");
    });
  });

  group('Adding to a to-many relationship', () {
    test('successfully adding a new identifier', () async {
      final r = await routingClient.addToRelationship(
          'books', '1', 'authors', [Identifier('people', '3')]);
      expect(r.isSuccessful, isTrue);
      expect(r.statusCode, 200);
      expect(r.data.unwrap().length, 3);
      expect(r.data.unwrap().first.id, '1');
      expect(r.data.unwrap().last.id, '3');

      final r1 = await routingClient.fetchResource('books', '1');
      expect(r1.data.unwrap().toMany['authors'].length, 3);
    });

    test('successfully adding an existing identifier', () async {
      final r = await routingClient.addToRelationship(
          'books', '1', 'authors', [Identifier('people', '2')]);
      expect(r.isSuccessful, isTrue);
      expect(r.statusCode, 200);
      expect(r.data.unwrap().length, 2);
      expect(r.data.unwrap().first.id, '1');
      expect(r.data.unwrap().last.id, '2');

      final r1 = await routingClient.fetchResource('books', '1');
      expect(r1.data.unwrap().toMany['authors'].length, 2);
    });

    test('404 when collection not found', () async {
      final r = await routingClient.addToRelationship(
          'unicorns', '1', 'breed', [Identifier('companies', '3')]);
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.data, isNull);
      final error = r.errors.first;
      expect(error.status, '404');
      expect(error.title, 'Collection not found');
      expect(error.detail, "Collection 'unicorns' does not exist");
    });

    test('404 when resource not found', () async {
      final r = await routingClient.addToRelationship(
          'books', '42', 'publisher', [Identifier('companies', '3')]);
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.data, isNull);
      final error = r.errors.first;
      expect(error.status, '404');
      expect(error.title, 'Resource not found');
      expect(error.detail, "Resource '42' does not exist in 'books'");
    });

    test('404 when relationship not found', () async {
      final r = await routingClient.addToRelationship(
          'books', '1', 'sellers', [Identifier('companies', '3')]);
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.data, isNull);
      final error = r.errors.first;
      expect(error.status, '404');
      expect(error.title, 'Relationship not found');
      expect(error.detail,
          "There is no to-many relationship 'sellers' in this resource");
    });
  });

  group('Deleting from a to-many relationship', () {
    test('successfully deleting an identifier', () async {
      final r = await routingClient.deleteFromToMany(
          'books', '1', 'authors', [Identifier('people', '1')]);
      expect(r.isSuccessful, isTrue);
      expect(r.statusCode, 200);
      expect(r.data.unwrap().length, 1);
      expect(r.data.unwrap().first.id, '2');

      final r1 = await routingClient.fetchResource('books', '1');
      expect(r1.data.unwrap().toMany['authors'].length, 1);
    });

    test('successfully deleting a non-present identifier', () async {
      final r = await routingClient.deleteFromToMany(
          'books', '1', 'authors', [Identifier('people', '3')]);
      expect(r.isSuccessful, isTrue);
      expect(r.statusCode, 200);
      expect(r.data.unwrap().length, 2);
      expect(r.data.unwrap().first.id, '1');
      expect(r.data.unwrap().last.id, '2');

      final r1 = await routingClient.fetchResource('books', '1');
      expect(r1.data.unwrap().toMany['authors'].length, 2);
    });

    test('404 when collection not found', () async {
      final r = await routingClient.deleteFromToMany(
          'unicorns', '1', 'breed', [Identifier('companies', '1')]);
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.data, isNull);
      final error = r.errors.first;
      expect(error.status, '404');
      expect(error.title, 'Collection not found');
      expect(error.detail, "Collection 'unicorns' does not exist");
    });

    test('404 when resource not found', () async {
      final r = await routingClient.deleteFromToMany(
          'books', '42', 'publisher', [Identifier('companies', '1')]);
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.data, isNull);
      final error = r.errors.first;
      expect(error.status, '404');
      expect(error.title, 'Resource not found');
      expect(error.detail, "Resource '42' does not exist in 'books'");
    });
  });
}
