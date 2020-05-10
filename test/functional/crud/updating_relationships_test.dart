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
  final routing = StandardRouting(base);

  setUp(() async {
    final repository =
        InMemoryRepository({'books': {}, 'people': {}, 'companies': {}});
    server = JsonApiServer(RepositoryController(repository));
    client = JsonApiClient(server, routing);

    await seedResources(client);
  });

  group('Updating a to-one relationship', () {
    test('204 No Content', () async {
      final r = await client.replaceOne(
          'books', '1', 'publisher', Ref('companies', '2'));
      expect(r.isSuccessful, isTrue);
      expect(r.http.statusCode, 204);

      final r1 = await client.fetchResource('books', '1');
      expect(r1.resource.one('publisher').identifier().id, '2');
    });

    test('404 on collection', () async {
      try {
        await client.replaceOne(
            'unicorns', '1', 'breed', Ref('companies', '2'));
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 404);
        expect(e.http.headers['content-type'], ContentType.jsonApi);
        expect(e.errors.first.status, '404');
        expect(e.errors.first.title, 'Collection not found');
        expect(e.errors.first.detail, "Collection 'unicorns' does not exist");
      }
    });

    test('404 on resource', () async {
      try {
        await client.replaceOne(
            'books', '42', 'publisher', Ref('companies', '2'));
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 404);
        expect(e.http.headers['content-type'], ContentType.jsonApi);
        expect(e.errors.first.status, '404');
        expect(e.errors.first.title, 'Resource not found');
        expect(
            e.errors.first.detail, "Resource '42' does not exist in 'books'");
      }
    });
  });

  group('Deleting a to-one relationship', () {
    test('204 No Content', () async {
      final r = await client.deleteOne('books', '1', 'publisher');
      expect(r.isSuccessful, isTrue);
      expect(r.http.statusCode, 204);

      final r1 = await client.fetchResource('books', '1');
      expect(r1.resource.one('publisher').isEmpty, true);
    });

    test('404 on collection', () async {
      try {
        await client.deleteOne('unicorns', '1', 'breed');
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 404);
        expect(e.http.headers['content-type'], ContentType.jsonApi);
        expect(e.errors.first.status, '404');
        expect(e.errors.first.title, 'Collection not found');
        expect(e.errors.first.detail, "Collection 'unicorns' does not exist");
      }
    });

    test('404 on resource', () async {
      try {
        await client.deleteOne('books', '42', 'publisher');
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 404);
        expect(e.http.headers['content-type'], ContentType.jsonApi);
        expect(e.errors.first.status, '404');
        expect(e.errors.first.title, 'Resource not found');
        expect(
            e.errors.first.detail, "Resource '42' does not exist in 'books'");
      }
    });
  });

  group('Replacing a to-many relationship', () {
    test('204 No Content', () async {
      final r = await client
          .replaceMany('books', '1', 'authors', [Ref('people', '1')]);
      expect(r.isSuccessful, isTrue);
      expect(r.http.statusCode, 204);

      final r1 = await client.fetchResource('books', '1');
      expect(r1.resource.many('authors').length, 1);
      expect(r1.resource.many('authors').first.id, '1');
    });

    test('404 on collection', () async {
      try {
        await client.replaceMany('unicorns', '1', 'breed', []);
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 404);
        expect(e.http.headers['content-type'], ContentType.jsonApi);
        expect(e.errors.first.status, '404');
        expect(e.errors.first.title, 'Collection not found');
        expect(e.errors.first.detail, "Collection 'unicorns' does not exist");
      }
    });

    test('404 on resource', () async {
      try {
        await client.replaceMany('books', '42', 'publisher', []);
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 404);
        expect(e.http.headers['content-type'], ContentType.jsonApi);
        expect(e.errors.first.status, '404');
        expect(e.errors.first.title, 'Resource not found');
        expect(
            e.errors.first.detail, "Resource '42' does not exist in 'books'");
      }
    });
  });

  group('Adding to a to-many relationship', () {
    test('successfully adding a new identifier', () async {
      final r =
          await client.addMany('books', '1', 'authors', [Ref('people', '3')]);
      expect(r.isSuccessful, isTrue);
      expect(r.http.statusCode, 200);
      expect(r.http.headers['content-type'], ContentType.jsonApi);
      expect(r.decodeDocument().data.linkage.length, 3);
      expect(r.decodeDocument().data.linkage.first.id, '1');
      expect(r.decodeDocument().data.linkage.last.id, '3');

      final r1 = await client.fetchResource('books', '1');
      expect(r1.resource.many('authors').length, 3);
    });

    test('successfully adding an existing identifier', () async {
      final r =
          await client.addMany('books', '1', 'authors', [Ref('people', '2')]);
      expect(r.isSuccessful, isTrue);
      expect(r.http.statusCode, 200);
      expect(r.http.headers['content-type'], ContentType.jsonApi);
      expect(r.decodeDocument().data.linkage.length, 2);
      expect(r.decodeDocument().data.linkage.first.id, '1');
      expect(r.decodeDocument().data.linkage.last.id, '2');

      final r1 = await client.fetchResource('books', '1');
      expect(r1.resource.many('authors').length, 2);
      expect(r1.http.headers['content-type'], ContentType.jsonApi);
    });

    test('404 on collection', () async {
      try {
        await client.addMany('unicorns', '1', 'breed', []);
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 404);
        expect(e.http.headers['content-type'], ContentType.jsonApi);
        expect(e.errors.first.status, '404');
        expect(e.errors.first.title, 'Collection not found');
        expect(e.errors.first.detail, "Collection 'unicorns' does not exist");
      }
    });

    test('404 on resource', () async {
      try {
        await client.addMany('books', '42', 'publisher', []);
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 404);
        expect(e.http.headers['content-type'], ContentType.jsonApi);
        expect(e.errors.first.status, '404');
        expect(e.errors.first.title, 'Resource not found');
        expect(
            e.errors.first.detail, "Resource '42' does not exist in 'books'");
      }
    });

    test('404 on relationship', () async {
      try {
        await client.addMany('books', '1', 'sellers', []);
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 404);
        expect(e.http.headers['content-type'], ContentType.jsonApi);
        expect(e.errors.first.status, '404');
        expect(e.errors.first.title, 'Relationship not found');
        expect(e.errors.first.detail,
            "There is no to-many relationship 'sellers' in this resource");
      }
    });
  });

  group('Deleting from a to-many relationship', () {
    test('successfully deleting an identifier', () async {
      final r = await client
          .deleteMany('books', '1', 'authors', [Ref('people', '1')]);
      expect(r.isSuccessful, isTrue);
      expect(r.http.statusCode, 200);
      expect(r.http.headers['content-type'], ContentType.jsonApi);
      expect(r.decodeDocument().data.linkage.length, 1);
      expect(r.decodeDocument().data.linkage.first.id, '2');

      final r1 = await client.fetchResource('books', '1');
      expect(r1.resource.many('authors').length, 1);
    });

    test('404 on collection', () async {
      try {
        await client.deleteMany('unicorns', '1', 'breed', []);
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 404);
        expect(e.http.headers['content-type'], ContentType.jsonApi);
        expect(e.errors.first.status, '404');
        expect(e.errors.first.title, 'Collection not found');
        expect(e.errors.first.detail, "Collection 'unicorns' does not exist");
      }
    });

    test('404 on resource', () async {
      try {
        await client.deleteMany('books', '42', 'publisher', []);
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 404);
        expect(e.http.headers['content-type'], ContentType.jsonApi);
        expect(e.errors.first.status, '404');
        expect(e.errors.first.title, 'Resource not found');
        expect(
            e.errors.first.detail, "Resource '42' does not exist in 'books'");
      }
    });

    test('404 on relationship', () async {
      try {
        await client.deleteMany('books', '1', 'sellers', []);
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 404);
        expect(e.http.headers['content-type'], ContentType.jsonApi);
        expect(e.errors.first.status, '404');
        expect(e.errors.first.title, 'Relationship not found');
        expect(e.errors.first.detail,
            "There is no to-many relationship 'sellers' in this resource");
      }
    });
  });
}
