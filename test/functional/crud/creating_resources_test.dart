import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../../helper/expect_resources_equal.dart';

void main() async {
  final host = 'localhost';
  final port = 80;
  final base = Uri(scheme: 'http', host: host, port: port);
  final routing = StandardRouting(base);

  group('Server-genrated ID', () {
    test('201 Created', () async {
      final repository = InMemoryRepository({
        'people': {},
      }, nextId: Uuid().v4);
      final server = JsonApiServer(RepositoryController(repository));
      final client = JsonApiClient(server);
      final routingClient = RoutingClient(client, routing);

      final person =
          NewResource('people', attributes: {'name': 'Martin Fowler'});
      final r = await routingClient.createResource(person);
      expect(r.statusCode, 201);
      expect(r.location, isNotNull);
      expect(r.location, r.data.links['self'].uri);
      final created = r.data.unwrap();
      expect(created.type, person.type);
      expect(created.id, isNotNull);
      expect(created.attributes, equals(person.attributes));
      final r1 = await client.fetchResourceAt(r.location);
      expect(r1.statusCode, 200);
      expectResourcesEqual(r1.data.unwrap(), created);
    });

    test('403 when the id can not be generated', () async {
      final repository = InMemoryRepository({'people': {}});
      final server = JsonApiServer(RepositoryController(repository));
      final client = JsonApiClient(server);
      final routingClient = RoutingClient(client, routing);

      final r = await routingClient.createResource(Resource('people', null));
      expect(r.statusCode, 403);
      expect(r.data, isNull);
      final error = r.errors.first;
      expect(error.status, '403');
      expect(error.title, 'Unsupported operation');
      expect(error.detail, 'Id generation is not supported');
    });
  });

  group('Client-genrated ID', () {
    JsonApiClient client;
    RoutingClient routingClient;
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
      client = JsonApiClient(server);
      routingClient = RoutingClient(client, routing);
    });

    test('204 No Content', () async {
      final person =
          Resource('people', '123', attributes: {'name': 'Martin Fowler'});
      final r = await routingClient.createResource(person);
      expect(r.isSuccessful, isTrue);
      expect(r.statusCode, 204);
      expect(r.location, isNull);
      expect(r.data, isNull);
      final r1 = await routingClient.fetchResource(person.type, person.id);
      expect(r1.isSuccessful, isTrue);
      expect(r1.statusCode, 200);
      expectResourcesEqual(r1.data.unwrap(), person);
    });

    test('404 when the collection does not exist', () async {
      final r = await routingClient.createResource(Resource('unicorns', null));
      expect(r.isSuccessful, isFalse);
      expect(r.isFailed, isTrue);
      expect(r.statusCode, 404);
      expect(r.data, isNull);
      final error = r.errors.first;
      expect(error.status, '404');
      expect(error.title, 'Collection not found');
      expect(error.detail, "Collection 'unicorns' does not exist");
    });

    test('404 when the related resource does not exist (to-one)', () async {
      final book = Resource('books', null,
          toOne: {'publisher': Identifier('companies', '123')});
      final r = await routingClient.createResource(book);
      expect(r.isSuccessful, isFalse);
      expect(r.isFailed, isTrue);
      expect(r.statusCode, 404);
      expect(r.data, isNull);
      final error = r.errors.first;
      expect(error.status, '404');
      expect(error.title, 'Resource not found');
      expect(error.detail, "Resource '123' does not exist in 'companies'");
    });

    test('404 when the related resource does not exist (to-many)', () async {
      final book = Resource('books', null, toMany: {
        'authors': [Identifier('people', '123')]
      });
      final r = await routingClient.createResource(book);
      expect(r.isSuccessful, isFalse);
      expect(r.isFailed, isTrue);
      expect(r.statusCode, 404);
      expect(r.data, isNull);
      final error = r.errors.first;
      expect(error.status, '404');
      expect(error.title, 'Resource not found');
      expect(error.detail, "Resource '123' does not exist in 'people'");
    });

    test('409 when the resource type does not match collection', () async {
      final r = await client.createResourceAt(
          routing.collection('fruits'), Resource('cucumbers', null));
      expect(r.isSuccessful, isFalse);
      expect(r.isFailed, isTrue);
      expect(r.statusCode, 409);
      expect(r.data, isNull);
      final error = r.errors.first;
      expect(error.status, '409');
      expect(error.title, 'Invalid resource type');
      expect(error.detail, "Type 'cucumbers' does not belong in 'fruits'");
    });

    test('409 when the resource with this id already exists', () async {
      final apple = Resource('apples', '123');
      await routingClient.createResource(apple);
      final r = await routingClient.createResource(apple);
      expect(r.isSuccessful, isFalse);
      expect(r.isFailed, isTrue);
      expect(r.statusCode, 409);
      expect(r.data, isNull);
      final error = r.errors.first;
      expect(error.status, '409');
      expect(error.title, 'Resource exists');
      expect(error.detail, 'Resource with this type and id already exists');
    });
  });
}
