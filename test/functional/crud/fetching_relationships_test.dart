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

  group('Generic', () {
    test('200 OK to-one', () async {
      final r = await client.fetchRelationship('books', '1', 'publisher');
      expect(r.http.statusCode, 200);
      expect(r.http.headers['content-type'], ContentType.jsonApi);
      final rel = r.relationship;
      expect(rel.isSingular, true);
      expect(rel.isPlural, false);
      expect(rel.first.type, 'companies');
      expect(rel.first.id, '1');
    });

    test('200 OK to-many', () async {
      final r = await client.fetchRelationship('books', '1', 'authors');
      expect(r.http.statusCode, 200);
      expect(r.http.headers['content-type'], ContentType.jsonApi);
      final rel = r.relationship;
      expect(rel.isSingular, false);
      expect(rel.isPlural, true);
      expect(rel.length, 2);
      expect(rel.first.id, '1');
      expect(rel.first.type, 'people');
      expect(rel.last.id, '2');
      expect(rel.last.type, 'people');
    });

    test('404 on collection', () async {
      try {
        await client.fetchRelationship('unicorns', '1', 'corns');
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
        await client.fetchRelationship('books', '42', 'authors');
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
        await client.fetchRelationship('books', '1', 'readers');
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 404);
        expect(e.http.headers['content-type'], ContentType.jsonApi);
        expect(e.errors.first.status, '404');
        expect(e.errors.first.title, 'Relationship not found');
        expect(e.errors.first.detail,
            "Relationship 'readers' does not exist in this resource");
      }
    });
  });
}
