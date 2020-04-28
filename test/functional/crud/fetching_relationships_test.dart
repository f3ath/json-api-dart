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
  group('To-one', () {
    test('200 OK', () async {
      final r = await client.fetchToOne('books', '1', 'publisher');
      expect(r.isSuccessful, isTrue);
      expect(r.http.statusCode, 200);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().data.links['self'].uri.toString(),
          '/books/1/relationships/publisher');
      expect(
          r.decodeDocument().data.links['related'].uri.toString(), '/books/1/publisher');
      expect(r.decodeDocument().data.linkage.type, 'companies');
      expect(r.decodeDocument().data.linkage.id, '1');
    });

    test('404 on collection', () async {
      final r = await client.fetchToOne('unicorns', '1', 'publisher');
      expect(r.isSuccessful, isFalse);
      expect(r.http.statusCode, 404);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().errors.first.status, '404');
      expect(r.decodeDocument().errors.first.title, 'Collection not found');
      expect(r.decodeDocument().errors.first.detail,
          "Collection 'unicorns' does not exist");
    });

    test('404 on resource', () async {
      final r = await client.fetchToOne('books', '42', 'publisher');
      expect(r.isSuccessful, isFalse);
      expect(r.http.statusCode, 404);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().errors.first.status, '404');
      expect(r.decodeDocument().errors.first.title, 'Resource not found');
      expect(r.decodeDocument().errors.first.detail,
          "Resource '42' does not exist in 'books'");
    });

    test('404 on relationship', () async {
      final r = await client.fetchToOne('books', '1', 'owner');
      expect(r.isSuccessful, isFalse);
      expect(r.http.statusCode, 404);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().errors.first.status, '404');
      expect(r.decodeDocument().errors.first.title, 'Relationship not found');
      expect(r.decodeDocument().errors.first.detail,
          "Relationship 'owner' does not exist in this resource");
    });
  });

  group('To-many', () {
    test('200 OK', () async {
      final r = await client.fetchToMany('books', '1', 'authors');
      expect(r.isSuccessful, isTrue);
      expect(r.http.statusCode, 200);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().data.linkage.length, 2);
      expect(r.decodeDocument().data.linkage.first.type, 'people');
      expect(r.decodeDocument().data.links['self'].uri.toString(),
          '/books/1/relationships/authors');
      expect(
          r.decodeDocument().data.links['related'].uri.toString(), '/books/1/authors');
    });

    test('404 on collection', () async {
      final r = await client.fetchToMany('unicorns', '1', 'athors');
      expect(r.isSuccessful, isFalse);
      expect(r.http.statusCode, 404);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().errors.first.status, '404');
      expect(r.decodeDocument().errors.first.title, 'Collection not found');
      expect(r.decodeDocument().errors.first.detail,
          "Collection 'unicorns' does not exist");
    });

    test('404 on resource', () async {
      final r = await client.fetchToMany('books', '42', 'authors');
      expect(r.isSuccessful, isFalse);
      expect(r.http.statusCode, 404);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().errors.first.status, '404');
      expect(r.decodeDocument().errors.first.title, 'Resource not found');
      expect(r.decodeDocument().errors.first.detail,
          "Resource '42' does not exist in 'books'");
    });

    test('404 on relationship', () async {
      final r = await client.fetchToMany('books', '1', 'readers');
      expect(r.isSuccessful, isFalse);
      expect(r.http.statusCode, 404);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().errors.first.status, '404');
      expect(r.decodeDocument().errors.first.title, 'Relationship not found');
      expect(r.decodeDocument().errors.first.detail,
          "Relationship 'readers' does not exist in this resource");
    });
  });

  group('Generic', () {
    test('200 OK to-one', () async {
      final r = await client.fetchRelationship('books', '1', 'publisher');
      expect(r.isSuccessful, isTrue);
      expect(r.http.statusCode, 200);
      expect(r.http.headers['content-type'], Document.contentType);
      final rel = r.decodeDocument().data;
      if (rel is ToOneObject) {
        expect(rel.linkage.type, 'companies');
        expect(rel.linkage.id, '1');
      } else {
        fail('Not a ToOne relationship');
      }
    });

    test('200 OK to-many', () async {
      final r = await client.fetchRelationship('books', '1', 'authors');
      expect(r.isSuccessful, isTrue);
      expect(r.http.statusCode, 200);
      expect(r.http.headers['content-type'], Document.contentType);
      final rel = r.decodeDocument().data;
      if (rel is ToManyObject) {
        expect(rel.linkage.length, 2);
        expect(rel.linkage.first.id, '1');
        expect(rel.linkage.first.type, 'people');
        expect(rel.linkage.last.id, '2');
        expect(rel.linkage.last.type, 'people');
      } else {
        fail('Not a ToMany relationship');
      }
    });

    test('404 on collection', () async {
      final r = await client.fetchRelationship('unicorns', '1', 'athors');
      expect(r.isSuccessful, isFalse);
      expect(r.http.statusCode, 404);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().errors.first.status, '404');
      expect(r.decodeDocument().errors.first.title, 'Collection not found');
      expect(r.decodeDocument().errors.first.detail,
          "Collection 'unicorns' does not exist");
    });

    test('404 on resource', () async {
      final r = await client.fetchRelationship('books', '42', 'authors');
      expect(r.isSuccessful, isFalse);
      expect(r.http.statusCode, 404);
      expect(r.http.headers['content-type'], Document.contentType);
      expect(r.decodeDocument().errors.first.status, '404');
      expect(r.decodeDocument().errors.first.title, 'Resource not found');
      expect(r.decodeDocument().errors.first.detail,
          "Resource '42' does not exist in 'books'");
    });

    test('404 on relationship', () async {
      final r = await client.fetchRelationship('books', '1', 'readers');
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
