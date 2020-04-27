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

  group('Primary Resource', () {
    test('200 OK', () async {
      final r = await client.fetchResource('books', '1');
      expect(r.isSuccessful, isTrue);
      expect(r.http.statusCode, 200);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().data.unwrap().id, '1');
      expect(
          r.decodeDocument().data.unwrap().attributes['title'], 'Refactoring');
      expect(r.decodeDocument().data.links['self'].uri.toString(), '/books/1');
      expect(
          r.decodeDocument().data.resourceObject.links['self'].uri.toString(),
          '/books/1');
      final authors =
          r.decodeDocument().data.resourceObject.relationships['authors'];
      expect(
          authors.links['self'].toString(), '/books/1/relationships/authors');
      expect(authors.related.toString(), '/books/1/authors');
      final publisher =
          r.decodeDocument().data.resourceObject.relationships['publisher'];
      expect(publisher.links['self'].toString(),
          '/books/1/relationships/publisher');
      expect(publisher.related.toString(), '/books/1/publisher');
    });

    test('404 on collection', () async {
      final r = await client.fetchResource('unicorns', '1');
      expect(r.isSuccessful, isFalse);
      expect(r.http.statusCode, 404);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().errors.first.status, '404');
      expect(r.decodeDocument().errors.first.title, 'Collection not found');
      expect(r.decodeDocument().errors.first.detail,
          "Collection 'unicorns' does not exist");
    });

    test('404 on resource', () async {
      final r = await client.fetchResource('people', '42');
      expect(r.isSuccessful, isFalse);
      expect(r.http.statusCode, 404);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().errors.first.status, '404');
      expect(r.decodeDocument().errors.first.title, 'Resource not found');
      expect(r.decodeDocument().errors.first.detail,
          "Resource '42' does not exist in 'people'");
    });
  });

  group('Primary collections', () {
    test('200 OK', () async {
      final r = await client.fetchCollection('people');
      expect(r.isSuccessful, isTrue);
      expect(r.http.statusCode, 200);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().data.links['self'].uri.toString(), '/people');
      expect(r.decodeDocument().data.collection.length, 3);
      expect(r.decodeDocument().data.collection.first.self.uri.toString(),
          '/people/1');
      expect(r.decodeDocument().data.collection.last.self.uri.toString(),
          '/people/3');
      expect(r.decodeDocument().data.unwrap().length, 3);
      expect(r.decodeDocument().data.unwrap().first.attributes['name'],
          'Martin Fowler');
      expect(r.decodeDocument().data.unwrap().last.attributes['name'],
          'Robert Martin');
    });

    test('404', () async {
      final r = await client.fetchCollection('unicorns');
      expect(r.isSuccessful, isFalse);
      expect(r.http.statusCode, 404);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().errors.first.status, '404');
      expect(r.decodeDocument().errors.first.title, 'Collection not found');
      expect(r.decodeDocument().errors.first.detail,
          "Collection 'unicorns' does not exist");
    });
  });

  group('Related Resource', () {
    test('200 OK', () async {
      final r = await client.fetchRelatedResource('books', '1', 'publisher');
      expect(r.isSuccessful, isTrue);
      expect(r.http.statusCode, 200);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().data.unwrap().type, 'companies');
      expect(r.decodeDocument().data.unwrap().id, '1');
      expect(r.decodeDocument().data.links['self'].uri.toString(),
          '/books/1/publisher');
      expect(
          r.decodeDocument().data.resourceObject.links['self'].uri.toString(),
          '/companies/1');
    });

    test('404 on collection', () async {
      final r = await client.fetchRelatedResource('unicorns', '1', 'publisher');
      expect(r.isSuccessful, isFalse);
      expect(r.http.statusCode, 404);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().errors.first.status, '404');
      expect(r.decodeDocument().errors.first.title, 'Collection not found');
      expect(r.decodeDocument().errors.first.detail,
          "Collection 'unicorns' does not exist");
    });

    test('404 on resource', () async {
      final r = await client.fetchRelatedResource('books', '42', 'publisher');
      expect(r.isSuccessful, isFalse);
      expect(r.http.statusCode, 404);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().errors.first.status, '404');
      expect(r.decodeDocument().errors.first.title, 'Resource not found');
      expect(r.decodeDocument().errors.first.detail,
          "Resource '42' does not exist in 'books'");
    });

    test('404 on relationship', () async {
      final r = await client.fetchRelatedResource('books', '1', 'owner');
      expect(r.isSuccessful, isFalse);
      expect(r.http.statusCode, 404);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().errors.first.status, '404');
      expect(r.decodeDocument().errors.first.title, 'Relationship not found');
      expect(r.decodeDocument().errors.first.detail,
          "Relationship 'owner' does not exist in this resource");
    });
  });

  group('Related Collection', () {
    test('successful', () async {
      final r = await client.fetchRelatedCollection('books', '1', 'authors');
      expect(r.isSuccessful, isTrue);
      expect(r.http.statusCode, 200);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().data.links['self'].uri.toString(),
          '/books/1/authors');
      expect(r.decodeDocument().data.collection.length, 2);
      expect(r.decodeDocument().data.collection.first.self.uri.toString(),
          '/people/1');
      expect(r.decodeDocument().data.collection.last.self.uri.toString(),
          '/people/2');
      expect(r.decodeDocument().data.unwrap().length, 2);
      expect(r.decodeDocument().data.unwrap().first.attributes['name'],
          'Martin Fowler');
      expect(r.decodeDocument().data.unwrap().last.attributes['name'],
          'Kent Beck');
    });

    test('404 on collection', () async {
      final r = await client.fetchRelatedCollection('unicorns', '1', 'athors');
      expect(r.isSuccessful, isFalse);
      expect(r.http.statusCode, 404);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().errors.first.status, '404');
      expect(r.decodeDocument().errors.first.title, 'Collection not found');
      expect(r.decodeDocument().errors.first.detail,
          "Collection 'unicorns' does not exist");
    });

    test('404 on resource', () async {
      final r = await client.fetchRelatedCollection('books', '42', 'authors');
      expect(r.isSuccessful, isFalse);
      expect(r.http.statusCode, 404);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().errors.first.status, '404');
      expect(r.decodeDocument().errors.first.title, 'Resource not found');
      expect(r.decodeDocument().errors.first.detail,
          "Resource '42' does not exist in 'books'");
    });

    test('404 on relationship', () async {
      final r = await client.fetchRelatedCollection('books', '1', 'readers');
      expect(r.isSuccessful, isFalse);
      expect(r.http.statusCode, 404);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().errors.first.status, '404');
      expect(r.decodeDocument().errors.first.title, 'Relationship not found');
      expect(r.decodeDocument().errors.first.detail,
          "Relationship 'readers' does not exist in this resource");
    });
  });
}
