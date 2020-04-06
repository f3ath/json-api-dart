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
  group('To-one', () {
    test('200 OK', () async {
      final r = await routingClient.fetchToOne('books', '1', 'publisher');
      expect(r.isSuccessful, isTrue);
      expect(r.statusCode, 200);
      expect(r.headers['content-type'], Document.contentType);
      expect(r.data.unwrap().type, 'companies');
      expect(r.data.unwrap().id, '1');
    });

    test('404 on collection', () async {
      final r = await routingClient.fetchToOne('unicorns', '1', 'publisher');
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.headers['content-type'], Document.contentType);
      expect(r.errors.first.status, '404');
      expect(r.errors.first.title, 'Collection not found');
      expect(r.errors.first.detail, "Collection 'unicorns' does not exist");
    });

    test('404 on resource', () async {
      final r = await routingClient.fetchToOne('books', '42', 'publisher');
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.headers['content-type'], Document.contentType);
      expect(r.errors.first.status, '404');
      expect(r.errors.first.title, 'Resource not found');
      expect(r.errors.first.detail, "Resource '42' does not exist in 'books'");
    });

    test('404 on relationship', () async {
      final r = await routingClient.fetchToOne('books', '1', 'owner');
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.headers['content-type'], Document.contentType);
      expect(r.errors.first.status, '404');
      expect(r.errors.first.title, 'Relationship not found');
      expect(r.errors.first.detail,
          "Relationship 'owner' does not exist in this resource");
    });
  });

  group('To-many', () {
    test('200 OK', () async {
      final r = await routingClient.fetchToMany('books', '1', 'authors');
      expect(r.isSuccessful, isTrue);
      expect(r.statusCode, 200);
      expect(r.headers['content-type'], Document.contentType);
      expect(r.data.unwrap().length, 2);
      expect(r.data.unwrap().first.type, 'people');
    });

    test('404 on collection', () async {
      final r = await routingClient.fetchToMany('unicorns', '1', 'athors');
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.headers['content-type'], Document.contentType);
      expect(r.errors.first.status, '404');
      expect(r.errors.first.title, 'Collection not found');
      expect(r.errors.first.detail, "Collection 'unicorns' does not exist");
    });

    test('404 on resource', () async {
      final r = await routingClient.fetchToMany('books', '42', 'authors');
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.headers['content-type'], Document.contentType);
      expect(r.errors.first.status, '404');
      expect(r.errors.first.title, 'Resource not found');
      expect(r.errors.first.detail, "Resource '42' does not exist in 'books'");
    });

    test('404 on relationship', () async {
      final r = await routingClient.fetchToMany('books', '1', 'readers');
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.headers['content-type'], Document.contentType);
      expect(r.errors.first.status, '404');
      expect(r.errors.first.title, 'Relationship not found');
      expect(r.errors.first.detail,
          "Relationship 'readers' does not exist in this resource");
    });
  });

  group('Generic', () {
    test('200 OK to-one', () async {
      final r =
          await routingClient.fetchRelationship('books', '1', 'publisher');
      expect(r.isSuccessful, isTrue);
      expect(r.statusCode, 200);
      expect(r.headers['content-type'], Document.contentType);
      final rel = r.data;
      if (rel is ToOne) {
        expect(rel.unwrap().type, 'companies');
        expect(rel.unwrap().id, '1');
      } else {
        fail('Not a ToOne relationship');
      }
    });

    test('200 OK to-many', () async {
      final r = await routingClient.fetchRelationship('books', '1', 'authors');
      expect(r.isSuccessful, isTrue);
      expect(r.statusCode, 200);
      expect(r.headers['content-type'], Document.contentType);
      final rel = r.data;
      if (rel is ToMany) {
        expect(rel.unwrap().length, 2);
        expect(rel.unwrap().first.id, '1');
        expect(rel.unwrap().first.type, 'people');
        expect(rel.unwrap().last.id, '2');
        expect(rel.unwrap().last.type, 'people');
      } else {
        fail('Not a ToMany relationship');
      }
    });

    test('404 on collection', () async {
      final r =
          await routingClient.fetchRelationship('unicorns', '1', 'athors');
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.headers['content-type'], Document.contentType);
      expect(r.errors.first.status, '404');
      expect(r.errors.first.title, 'Collection not found');
      expect(r.errors.first.detail, "Collection 'unicorns' does not exist");
    });

    test('404 on resource', () async {
      final r = await routingClient.fetchRelationship('books', '42', 'authors');
      expect(r.isSuccessful, isFalse);
      expect(r.statusCode, 404);
      expect(r.headers['content-type'], Document.contentType);
      expect(r.errors.first.status, '404');
      expect(r.errors.first.title, 'Resource not found');
      expect(r.errors.first.detail, "Resource '42' does not exist in 'books'");
    });

    test('404 on relationship', () async {
      final r = await routingClient.fetchRelationship('books', '1', 'readers');
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
