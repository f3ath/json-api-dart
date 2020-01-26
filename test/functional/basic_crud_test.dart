import 'dart:io';

import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/server/repository/in_memory.dart';
import 'package:json_api/src/server/repository_controller.dart';
import 'package:json_api/uri_design.dart';
import 'package:shelf/shelf_io.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../helper/shelf_request_response_converter.dart';

void main() async {
  HttpServer server;
  UriAwareClient client;
  final host = 'localhost';
  final port = 8081;
  final base = Uri(scheme: 'http', host: host, port: port);
  final design = UriDesign.standard(base);

  setUp(() async {
    client = UriAwareClient(design);
    server = await serve(
        RequestHandler(
            ShelfRequestResponseConverter(),
            RepositoryController(InMemoryRepository({
              'books': {},
              'people': {},
              'companies': {},
              'noServerId': {},
              'fruits': {},
              'apples': {}
            }, generateId: (_) => _ == 'noServerId' ? null : Uuid().v4())),
            design),
        host,
        port);
  });

  tearDown(() async {
    client.close();
    await server.close();
  });

  group('Creating Resources', () {
    test('id generated on the server', () async {
      final person =
          Resource('people', null, attributes: {'name': 'Martin Fowler'});
      final r = await client.createResource(person);
      expect(r.isSuccessful, isTrue);
      expect(r.isFailed, isFalse);
      expect(r.statusCode, 201);
      expect(r.location, isNotNull);
      final created = r.data.unwrap();
      expect(created.type, person.type);
      expect(created.id, isNotNull);
      expect(created.attributes, equals(person.attributes));
      final r1 = await JsonApiClient().fetchResource(r.location);
      expect(r1.isSuccessful, isTrue);
      expect(r1.statusCode, 200);
      expectResourcesEqual(r1.data.unwrap(), created);
    });

    test('id generated on the client, the resource is not modified', () async {
      final person =
          Resource('people', '123', attributes: {'name': 'Martin Fowler'});
      final r = await client.createResource(person);
      expect(r.isSuccessful, isTrue);
      expect(r.statusCode, 204);
      expect(r.location, isNull);
      expect(r.data, isNull);
      final r1 = await client.fetchResource(person.type, person.id);
      expect(r1.isSuccessful, isTrue);
      expect(r1.statusCode, 200);
      expectResourcesEqual(r1.data.unwrap(), person);
    });

    test('403 when the id can not be generated', () async {
      final r = await client.createResource(Resource('noServerId', null));
      expect(r.isSuccessful, isFalse);
      expect(r.isFailed, isTrue);
      expect(r.statusCode, 403);
      expect(r.data, isNull);
      final error = r.errors.first;
      expect(error.status, '403');
      expect(error.title, 'Unsupported operation');
      expect(error.detail, 'Id generation is not supported');
    });

    test('404 when the collection does not exist', () async {
      final r = await client.createResource(Resource('unicorns', null));
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
      final r = await client.createResource(book);
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
      final r = await client.createResource(book);
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
      final r = await JsonApiClient().createResource(
          design.collectionUri('fruits'), Resource('cucumbers', null));
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
      await client.createResource(apple);
      final r = await client.createResource(apple);
      expect(r.isSuccessful, isFalse);
      expect(r.isFailed, isTrue);
      expect(r.statusCode, 409);
      expect(r.data, isNull);
      final error = r.errors.first;
      expect(error.status, '409');
      expect(error.title, 'Resource exists');
      expect(error.detail, 'Resource with this type and id already exists');
    });
  }, testOn: 'vm');

  group('Updating Resources and Relationships', () {
    setUp(() async {
      await client.createResource(
          Resource('people', '1', attributes: {'name': 'Martin Fowler'}));
      await client.createResource(
          Resource('people', '2', attributes: {'name': 'Kent Beck'}));
      await client.createResource(
          Resource('people', '3', attributes: {'name': 'Robert Martin'}));
      await client.createResource(Resource('companies', '1',
          attributes: {'name': 'Addison-Wesley Professional'}));
      await client.createResource(
          Resource('companies', '2', attributes: {'name': 'Prentice Hall'}));
      await client.createResource(Resource('books', '1', attributes: {
        'title': 'Refactoring',
        'ISBN-10': '0134757599'
      }, toOne: {
        'publisher': Identifier('companies', '1')
      }, toMany: {
        'authors': [Identifier('people', '1'), Identifier('people', '2')]
      }));
    });

    group('Resources', () {
      test('Update resource attributes and relationships', () async {
        final r =
            await client.updateResource(Resource('books', '1', attributes: {
          'title': 'Refactoring. Improving the Design of Existing Code',
          'pages': 448
        }, toOne: {
          'publisher': null
        }, toMany: {
          'authors': [Identifier('people', '1')],
          'reviewers': [Identifier('people', '2')]
        }));
        expect(r.isSuccessful, isTrue);
        expect(r.statusCode, 200);
        expect(r.data.unwrap().attributes['title'],
            'Refactoring. Improving the Design of Existing Code');
        expect(r.data.unwrap().attributes['pages'], 448);
        expect(r.data.unwrap().attributes['ISBN-10'], '0134757599');
        expect(r.data.unwrap().toOne['publisher'], isNull);
        expect(r.data.unwrap().toMany['authors'],
            equals([Identifier('people', '1')]));
        expect(r.data.unwrap().toMany['reviewers'],
            equals([Identifier('people', '2')]));

        final r1 = await client.fetchResource('books', '1');
        expectResourcesEqual(r1.data.unwrap(), r.data.unwrap());
      });

      test('404 when the target resource does not exist', () async {
        final r =
            await client.updateResource(Resource('books', '42'), id: '42');
        expect(r.isSuccessful, isFalse);
        expect(r.statusCode, 404);
        expect(r.data, isNull);
        final error = r.errors.first;
        expect(error.status, '404');
        expect(error.title, 'Resource not found');
        expect(error.detail, "Resource '42' does not exist in 'books'");
      });

      test('409 when the resource type does not match the collection',
          () async {
        final r = await client.updateResource(Resource('books', '1'),
            collection: 'people');
        expect(r.isSuccessful, isFalse);
        expect(r.statusCode, 409);
        expect(r.data, isNull);
        final error = r.errors.first;
        expect(error.status, '409');
        expect(error.title, 'Invalid resource type');
        expect(error.detail, "Type 'books' does not belong in 'people'");
      });
    });

    group('Updatng a to-one relationship', () {
      test('successfully', () async {
        final r = await client.replaceToOne(
            'books', '1', 'publisher', Identifier('companies', '2'));
        expect(r.isSuccessful, isTrue);
        expect(r.statusCode, 204);
        expect(r.data, isNull);

        final r1 = await client.fetchResource('books', '1');
        expect(r1.data.unwrap().toOne['publisher'].id, '2');
      });

      test('404 when collection not found', () async {
        final r = await client.replaceToOne(
            'unicorns', '1', 'breed', Identifier('companies', '2'));
        expect(r.isSuccessful, isFalse);
        expect(r.statusCode, 404);
        expect(r.data, isNull);
        final error = r.errors.first;
        expect(error.status, '404');
        expect(error.title, 'Collection not found');
        expect(error.detail, "Collection 'unicorns' does not exist");
      });

      test('404 when resource not found', () async {
        final r = await client.replaceToOne(
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
      test('successfully', () async {
        final r = await client.deleteToOne('books', '1', 'publisher');
        expect(r.isSuccessful, isTrue);
        expect(r.statusCode, 204);
        expect(r.data, isNull);

        final r1 = await client.fetchResource('books', '1');
        expect(r1.data.unwrap().toOne['publisher'], isNull);
      });

      test('404 when collection not found', () async {
        final r = await client.deleteToOne('unicorns', '1', 'breed');
        expect(r.isSuccessful, isFalse);
        expect(r.statusCode, 404);
        expect(r.data, isNull);
        final error = r.errors.first;
        expect(error.status, '404');
        expect(error.title, 'Collection not found');
        expect(error.detail, "Collection 'unicorns' does not exist");
      });

      test('404 when resource not found', () async {
        final r = await client.deleteToOne('books', '42', 'publisher');
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
      test('successfully', () async {
        final r = await client.replaceToMany(
            'books', '1', 'authors', [Identifier('people', '1')]);
        expect(r.isSuccessful, isTrue);
        expect(r.statusCode, 204);
        expect(r.data, isNull);

        final r1 = await client.fetchResource('books', '1');
        expect(r1.data.unwrap().toMany['authors'].length, 1);
        expect(r1.data.unwrap().toMany['authors'].first.id, '1');
      });

      test('404 when collection not found', () async {
        final r = await client.replaceToMany(
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
        final r = await client.replaceToMany(
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
      test('successfully', () async {
        final r = await client.addToRelationship(
            'books', '1', 'authors', [Identifier('people', '3')]);
        expect(r.isSuccessful, isTrue);
        expect(r.statusCode, 200);
        expect(r.data.unwrap().length, 3);
        expect(r.data.unwrap().first.id, '1');
        expect(r.data.unwrap().last.id, '3');

        final r1 = await client.fetchResource('books', '1');
        expect(r1.data.unwrap().toMany['authors'].length, 3);
      });

      test('404 when collection not found', () async {
        final r = await client.addToRelationship(
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
        final r = await client.addToRelationship(
            'books', '42', 'publisher', [Identifier('companies', '3')]);
        expect(r.isSuccessful, isFalse);
        expect(r.statusCode, 404);
        expect(r.data, isNull);
        final error = r.errors.first;
        expect(error.status, '404');
        expect(error.title, 'Resource not found');
        expect(error.detail, "Resource '42' does not exist in 'books'");
      });
    });
  }, testOn: 'vm');
}

void expectResourcesEqual(Resource a, Resource b) {
  expect(a.type, equals(b.type));
  expect(a.id, equals(b.id));
  expect(a.attributes, equals(b.attributes));
  expect(a.toOne, equals(b.toOne));
  expect(a.toMany, equals(b.toMany));
}
