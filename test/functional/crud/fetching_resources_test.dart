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

  group('Primary Resource', () {
    test('200 OK', () async {
      final r = await client.fetchResource('books', '1');
      expect(r.http.statusCode, 200);
      expect(r.http.headers['content-type'], ContentType.jsonApi);
      expect(r.resource.id, '1');
      expect(r.resource.attributes['title'], 'Refactoring');
      expect(r.links['self'].toString(), '/books/1');
      expect(r.links['self'].toString(), '/books/1');
      final authors = r.resource.relationships['authors'];
      expect(
          authors.links['self'].toString(), '/books/1/relationships/authors');
      expect(authors.links['related'].toString(), '/books/1/authors');
      final publisher = r.resource.relationships['publisher'];
      expect(publisher.links['self'].toString(),
          '/books/1/relationships/publisher');
      expect(publisher.links['related'].toString(), '/books/1/publisher');
    });

    test('404 on collection', () async {
      try {
        await client.fetchResource('unicorns', '1');
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
        await client.fetchResource('people', '42');
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 404);
        expect(e.http.headers['content-type'], ContentType.jsonApi);
        expect(e.errors.first.status, '404');
        expect(e.errors.first.title, 'Resource not found');
        expect(
            e.errors.first.detail, "Resource '42' does not exist in 'people'");
      }
    });
  });

  group('Primary collections', () {
    test('200 OK', () async {
      final r = await client.fetchCollection('people');
      expect(r.http.statusCode, 200);
      expect(r.http.headers['content-type'], ContentType.jsonApi);
      expect(r.links['self'].uri.toString(), '/people');
      expect(r.length, 3);
      expect(r.first.links['self'].toString(), '/people/1');
      expect(r.last.links['self'].toString(), '/people/3');
      expect(r.first.attributes['name'], 'Martin Fowler');
      expect(r.last.attributes['name'], 'Robert Martin');
    });

    test('404 on collection', () async {
      try {
        await client.fetchCollection('unicorns');
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 404);
        expect(e.http.headers['content-type'], ContentType.jsonApi);
        expect(e.errors.first.status, '404');
        expect(e.errors.first.title, 'Collection not found');
        expect(e.errors.first.detail, "Collection 'unicorns' does not exist");
      }
    });
  });

  group('Related Resource', () {
    test('200 OK', () async {
      final r = await client.fetchRelatedResource('books', '1', 'publisher');
      expect(r.http.statusCode, 200);
      expect(r.http.headers['content-type'], ContentType.jsonApi);
      expect(r.resource().type, 'companies');
      expect(r.resource().id, '1');
      expect(r.links['self'].toString(), '/books/1/publisher');
      expect(r.resource().links['self'].toString(), '/companies/1');
    });

    test('200 OK with empty resource', () async {
      final r = await client.fetchRelatedResource('books', '1', 'reviewer');
      expect(r.http.statusCode, 200);
      expect(r.http.headers['content-type'], ContentType.jsonApi);
      expect(() => r.resource(), throwsStateError);
      expect(r.resource(orElse: () => null), isNull);
      expect(r.links['self'].toString(), '/books/1/reviewer');
    });

    test('404 on collection', () async {
      try {
        await client.fetchRelatedResource('unicorns', '1', 'publisher');
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
        await client.fetchRelatedResource('books', '42', 'publisher');
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
        await client.fetchRelatedResource('books', '1', 'owner');
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 404);
        expect(e.http.headers['content-type'], ContentType.jsonApi);
        expect(e.errors.first.status, '404');
        expect(e.errors.first.title, 'Relationship not found');
        expect(e.errors.first.detail,
            "Relationship 'owner' does not exist in this resource");
      }
    });
  });

  group('Related Collection', () {
    test('successful', () async {
      final r = await client.fetchRelatedCollection('books', '1', 'authors');
      expect(r.http.statusCode, 200);
      expect(r.http.headers['content-type'], ContentType.jsonApi);
      expect(r.links['self'].uri.toString(), '/books/1/authors');
      expect(r.length, 2);
      expect(r.first.links['self'].toString(), '/people/1');
      expect(r.last.links['self'].toString(), '/people/2');
      expect(r.first.attributes['name'], 'Martin Fowler');
      expect(r.last.attributes['name'], 'Kent Beck');
    });

    test('404 on collection', () async {
      try {
        await client.fetchRelatedCollection('unicorns', '1', 'corns');
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
        await client.fetchRelatedCollection('books', '42', 'authors');
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
        await client.fetchRelatedCollection('books', '1', 'owner');
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 404);
        expect(e.http.headers['content-type'], ContentType.jsonApi);
        expect(e.errors.first.status, '404');
        expect(e.errors.first.title, 'Relationship not found');
        expect(e.errors.first.detail,
            "Relationship 'owner' does not exist in this resource");
      }
    });
  });
}
