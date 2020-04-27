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

  group('Updatng a to-one relationship', () {
    test('204 No Content', () async {
      final r = await client.replaceToOne(
          'books', '1', 'publisher', Identifier('companies', '2'));
      expect(r.isSuccessful, isTrue);
      expect(r.http.statusCode, 204);

      final r1 = await client.fetchResource('books', '1');
      expect(r1.decodeDocument().data.unwrap().toOne['publisher'].id, '2');
    });

    test('404 on collection', () async {
      final r = await client.replaceToOne(
          'unicorns', '1', 'breed', Identifier('companies', '2'));
      expect(r.isSuccessful, isFalse);
      expect(r.http.statusCode, 404);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().data, isNull);
      final error = r.decodeDocument().errors.first;
      expect(error.status, '404');
      expect(error.title, 'Collection not found');
      expect(error.detail, "Collection 'unicorns' does not exist");
    });

    test('404 on resource', () async {
      final r = await client.replaceToOne(
          'books', '42', 'publisher', Identifier('companies', '2'));
      expect(r.isSuccessful, isFalse);
      expect(r.http.statusCode, 404);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().data, isNull);
      final error = r.decodeDocument().errors.first;
      expect(error.status, '404');
      expect(error.title, 'Resource not found');
      expect(error.detail, "Resource '42' does not exist in 'books'");
    });
  });

  group('Deleting a to-one relationship', () {
    test('204 No Content', () async {
      final r = await client.deleteToOne('books', '1', 'publisher');
      expect(r.isSuccessful, isTrue);
      expect(r.http.statusCode, 204);

      final r1 = await client.fetchResource('books', '1');
      expect(r1.decodeDocument().data.unwrap().toOne['publisher'], isNull);
    });

    test('404 on collection', () async {
      final r = await client.deleteToOne('unicorns', '1', 'breed');
      expect(r.isSuccessful, isFalse);
      expect(r.http.statusCode, 404);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().data, isNull);
      final error = r.decodeDocument().errors.first;
      expect(error.status, '404');
      expect(error.title, 'Collection not found');
      expect(error.detail, "Collection 'unicorns' does not exist");
    });

    test('404 on resource', () async {
      final r = await client.deleteToOne('books', '42', 'publisher');
      expect(r.isSuccessful, isFalse);
      expect(r.http.statusCode, 404);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().data, isNull);
      final error = r.decodeDocument().errors.first;
      expect(error.status, '404');
      expect(error.title, 'Resource not found');
      expect(error.detail, "Resource '42' does not exist in 'books'");
    });
  });

  group('Replacing a to-many relationship', () {
    test('204 No Content', () async {
      final r = await client
          .replaceToMany('books', '1', 'authors', [Identifier('people', '1')]);
      expect(r.isSuccessful, isTrue);
      expect(r.http.statusCode, 204);

      final r1 = await client.fetchResource('books', '1');
      expect(r1.decodeDocument().data.unwrap().toMany['authors'].length, 1);
      expect(r1.decodeDocument().data.unwrap().toMany['authors'].first.id, '1');
    });

    test('404 when collection not found', () async {
      final r = await client.replaceToMany(
          'unicorns', '1', 'breed', [Identifier('companies', '2')]);
      expect(r.isSuccessful, isFalse);
      expect(r.http.statusCode, 404);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().data, isNull);
      final error = r.decodeDocument().errors.first;
      expect(error.status, '404');
      expect(error.title, 'Collection not found');
      expect(error.detail, "Collection 'unicorns' does not exist");
    });

    test('404 when resource not found', () async {
      final r = await client.replaceToMany(
          'books', '42', 'publisher', [Identifier('companies', '2')]);
      expect(r.isSuccessful, isFalse);
      expect(r.http.statusCode, 404);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().data, isNull);
      final error = r.decodeDocument().errors.first;
      expect(error.status, '404');
      expect(error.title, 'Resource not found');
      expect(error.detail, "Resource '42' does not exist in 'books'");
    });
  });

  group('Adding to a to-many relationship', () {
    test('successfully adding a new identifier', () async {
      final r = await client
          .addToMany('books', '1', 'authors', [Identifier('people', '3')]);
      expect(r.isSuccessful, isTrue);
      expect(r.http.statusCode, 200);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().data.linkage.length, 3);
      expect(r.decodeDocument().data.linkage.first.id, '1');
      expect(r.decodeDocument().data.linkage.last.id, '3');

      final r1 = await client.fetchResource('books', '1');
      expect(r1.decodeDocument().data.unwrap().toMany['authors'].length, 3);
    });

    test('successfully adding an existing identifier', () async {
      final r = await client
          .addToMany('books', '1', 'authors', [Identifier('people', '2')]);
      expect(r.isSuccessful, isTrue);
      expect(r.http.statusCode, 200);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().data.linkage.length, 2);
      expect(r.decodeDocument().data.linkage.first.id, '1');
      expect(r.decodeDocument().data.linkage.last.id, '2');

      final r1 = await client.fetchResource('books', '1');
      expect(r1.decodeDocument().data.unwrap().toMany['authors'].length, 2);
      expect(r1.http.headers['content-type'], Document.contentType);
    });

    test('404 when collection not found', () async {
      final r = await client
          .addToMany('unicorns', '1', 'breed', [Identifier('companies', '3')]);
      expect(r.isSuccessful, isFalse);
      expect(r.http.statusCode, 404);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().data, isNull);
      final error = r.decodeDocument().errors.first;
      expect(error.status, '404');
      expect(error.title, 'Collection not found');
      expect(error.detail, "Collection 'unicorns' does not exist");
    });

    test('404 when resource not found', () async {
      final r = await client.addToMany(
          'books', '42', 'publisher', [Identifier('companies', '3')]);
      expect(r.isSuccessful, isFalse);
      expect(r.http.statusCode, 404);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().data, isNull);
      final error = r.decodeDocument().errors.first;
      expect(error.status, '404');
      expect(error.title, 'Resource not found');
      expect(error.detail, "Resource '42' does not exist in 'books'");
    });

    test('404 when relationship not found', () async {
      final r = await client
          .addToMany('books', '1', 'sellers', [Identifier('companies', '3')]);
      expect(r.isSuccessful, isFalse);
      expect(r.http.statusCode, 404);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().data, isNull);
      final error = r.decodeDocument().errors.first;
      expect(error.status, '404');
      expect(error.title, 'Relationship not found');
      expect(error.detail,
          "There is no to-many relationship 'sellers' in this resource");
    });
  });

  group('Deleting from a to-many relationship', () {
    test('successfully deleting an identifier', () async {
      final r = await client.deleteFromToMany(
          'books', '1', 'authors', [Identifier('people', '1')]);
      expect(r.isSuccessful, isTrue);
      expect(r.http.statusCode, 200);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().data.linkage.length, 1);
      expect(r.decodeDocument().data.linkage.first.id, '2');

      final r1 = await client.fetchResource('books', '1');
      expect(r1.decodeDocument().data.unwrap().toMany['authors'].length, 1);
    });

    test('successfully deleting a non-present identifier', () async {
      final r = await client.deleteFromToMany(
          'books', '1', 'authors', [Identifier('people', '3')]);
      expect(r.isSuccessful, isTrue);
      expect(r.http.statusCode, 200);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().data.linkage.length, 2);
      expect(r.decodeDocument().data.linkage.first.id, '1');
      expect(r.decodeDocument().data.linkage.last.id, '2');

      final r1 = await client.fetchResource('books', '1');
      expect(r1.decodeDocument().data.unwrap().toMany['authors'].length, 2);
    });

    test('404 when collection not found', () async {
      final r = await client.deleteFromToMany(
          'unicorns', '1', 'breed', [Identifier('companies', '1')]);
      expect(r.isSuccessful, isFalse);
      expect(r.http.statusCode, 404);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().data, isNull);
      final error = r.decodeDocument().errors.first;
      expect(error.status, '404');
      expect(error.title, 'Collection not found');
      expect(error.detail, "Collection 'unicorns' does not exist");
    });

    test('404 when resource not found', () async {
      final r = await client.deleteFromToMany(
          'books', '42', 'publisher', [Identifier('companies', '1')]);
      expect(r.isSuccessful, isFalse);
      expect(r.http.statusCode, 404);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().data, isNull);
      final error = r.decodeDocument().errors.first;
      expect(error.status, '404');
      expect(error.title, 'Resource not found');
      expect(error.detail, "Resource '42' does not exist in 'books'");
    });
  });
}
