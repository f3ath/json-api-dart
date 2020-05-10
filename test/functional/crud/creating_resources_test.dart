import 'package:json_api/client.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../../helper/expect_same_json.dart';

void main() async {
  final host = 'localhost';
  final port = 80;
  final base = Uri(scheme: 'http', host: host, port: port);
  final urls = StandardRouting(base);

  group('Server-generated ID', () {
    test('201 Created', () async {
      final repository = InMemoryRepository({
        'people': {},
      }, nextId: Uuid().v4);
      final server = JsonApiServer(RepositoryController(repository));
      final client = JsonApiClient(server, urls);

      final r = await client
          .createNewResource('people', attributes: {'name': 'Martin Fowler'});
      expect(r.http.statusCode, 201);
      expect(r.http.headers['content-type'], ContentType.jsonApi);
      expect(r.http.headers['location'], isNotNull);
      expect(r.http.headers['location'],
          r.decodeDocument().data.links['self'].uri.toString());
      final created = r.decodeDocument().data.unwrap();
      expect(created.type, 'people');
      expect(created.id, isNotNull);
      expect(created.attributes, equals({'name': 'Martin Fowler'}));
      final r1 = await client.send(
          Request.fetchResource(), Uri.parse(r.http.headers['location']));
      expect(r1.http.statusCode, 200);
      expectSameJson(r1.decodeDocument().data.unwrap(), created);
    });

    test('403 when the id can not be generated', () async {
      final repository = InMemoryRepository({'people': {}});
      final server = JsonApiServer(RepositoryController(repository));
      final client = JsonApiClient(server, urls);

      try {
        await client.createNewResource('people');
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 403);
        expect(e.errors.first.status, '403');
        expect(e.errors.first.title, 'Unsupported operation');
        expect(e.errors.first.detail, 'Id generation is not supported');
      }
    });
  });

  group('Client-generated ID', () {
    JsonApiClient client;
    setUp(() async {
      final repository = InMemoryRepository({
        'books': {},
        'people': {},
        'companies': {},
        'noServerId': {},
        'fruits': {},
        'apples': {}
      });
      final server = JsonApiServer(RepositoryController(repository));
      client = JsonApiClient(server, urls);
    });

    test('204 No Content', () async {
      final r = await client.createResource('people', '123',
          attributes: {'name': 'Martin Fowler'});
      expect(r.isSuccessful, isTrue);
      expect(r.http.statusCode, 204);
      expect(r.http.headers['location'], isNull);
      final r1 = await client.fetchResource('people', '123');
      expect(r1.isSuccessful, isTrue);
      expect(r1.http.statusCode, 200);
      expectSameJson(r1.decodeDocument().data.unwrap(), {
        'type': 'people',
        'id': '123',
        'attributes': {'name': 'Martin Fowler'}
      });
    });

    test('404 when the collection does not exist', () async {
      try {
        await client.createNewResource('unicorns');
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 404);
        expect(e.http.headers['content-type'], ContentType.jsonApi);
        expect(e.errors.first.status, '404');
        expect(e.errors.first.title, 'Collection not found');
        expect(e.errors.first.detail, "Collection 'unicorns' does not exist");
      }
    });

    test('404 when the related resource does not exist (to-one)', () async {
      try {
        await client.createNewResource('books',
            one: {'publisher': Identifier('companies', '123')});
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 404);
        expect(e.http.headers['content-type'], ContentType.jsonApi);
        expect(e.errors.first.status, '404');
        expect(e.errors.first.title, 'Resource not found');
        expect(e.errors.first.detail,
            "Resource '123' does not exist in 'companies'");
      }
    });

    test('404 when the related resource does not exist (to-many)', () async {
      try {
        await client.createNewResource('books', many: {
          'authors': [Identifier('people', '123')]
        });
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 404);
        expect(e.http.headers['content-type'], ContentType.jsonApi);
        expect(e.errors.first.status, '404');
        expect(e.errors.first.title, 'Resource not found');
        expect(
            e.errors.first.detail, "Resource '123' does not exist in 'people'");
      }
    });
//
//    test('409 when the resource type does not match collection', () async {
//      final r = await client.send(
//          Request.createResource(
//              Document(ResourceData.fromResource(Resource('cucumbers', null)))),
//          urls.collection('fruits'));
//      expect(r.isSuccessful, isFalse);
//      expect(r.isFailed, isTrue);
//      expect(r.http.statusCode, 409);
//      expect(r.http.headers['content-type'], Document.contentType);
//      expect(r.decodeDocument().data, isNull);
//      final error = r.decodeDocument().errors.first;
//      expect(error.status, '409');
//      expect(error.title, 'Invalid resource type');
//      expect(error.detail, "Type 'cucumbers' does not belong in 'fruits'");
//    });

    test('409 when the resource with this id already exists', () async {
      await client.createResource('apples', '123');
      try {
        await client.createResource('apples', '123');
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 409);
        expect(e.http.headers['content-type'], ContentType.jsonApi);
        expect(e.errors.first.status, '409');
        expect(e.errors.first.title, 'Resource exists');
        expect(e.errors.first.detail,
            'Resource with this type and id already exists');
      }
    });
  });
}
