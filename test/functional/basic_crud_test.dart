import 'dart:io';

import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:json_api/query.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/server/repository/in_memory_repository.dart';
import 'package:json_api/src/server/repository_controller.dart';
import 'package:json_api/uri_design.dart';
import 'package:shelf/shelf_io.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../helper/expect_resources_equal.dart';
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

  group('Updating and Fetching Resources and Relationships', () {
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

    group('Updating Resources', () {
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

    group('Fetching Resource', () {
      test('successful', () async {
        final r = await client.fetchResource('people', '1');
        expect(r.isSuccessful, isTrue);
        expect(r.statusCode, 200);
        expect(r.data.unwrap().id, '1');
      });

      test('successful compound', () async {
        final r =
            await client.fetchResource('books', '1', parameters: Include(['']));
        expect(r.isSuccessful, isTrue);
        expect(r.statusCode, 200);
        expect(r.data.unwrap().id, '1');
      });

      test('404 on collection', () async {
        final r = await client.fetchResource('unicorns', '1');
        expect(r.isSuccessful, isFalse);
        expect(r.statusCode, 404);
        expect(r.errors.first.status, '404');
        expect(r.errors.first.title, 'Collection not found');
        expect(r.errors.first.detail, "Collection 'unicorns' does not exist");
      });

      test('404 on resource', () async {
        final r = await client.fetchResource('people', '42');
        expect(r.isSuccessful, isFalse);
        expect(r.statusCode, 404);
        expect(r.errors.first.status, '404');
        expect(r.errors.first.title, 'Resource not found');
        expect(
            r.errors.first.detail, "Resource '42' does not exist in 'people'");
      });
    });

    group('Fetching Resources with', () {
      test('successful', () async {
        final r = await client.fetchResource('people', '1');
        expect(r.isSuccessful, isTrue);
        expect(r.statusCode, 200);
        expect(r.data.unwrap().id, '1');
      });

      test('404 on collection', () async {
        final r = await client.fetchResource('unicorns', '1');
        expect(r.isSuccessful, isFalse);
        expect(r.statusCode, 404);
        expect(r.errors.first.status, '404');
        expect(r.errors.first.title, 'Collection not found');
        expect(r.errors.first.detail, "Collection 'unicorns' does not exist");
      });

      test('404 on resource', () async {
        final r = await client.fetchResource('people', '42');
        expect(r.isSuccessful, isFalse);
        expect(r.statusCode, 404);
        expect(r.errors.first.status, '404');
        expect(r.errors.first.title, 'Resource not found');
        expect(
            r.errors.first.detail, "Resource '42' does not exist in 'people'");
      });
    });

    group('Fetching primary collections', () {
      test('successful', () async {
        final r = await client.fetchCollection('people');
        expect(r.isSuccessful, isTrue);
        expect(r.statusCode, 200);
        expect(r.data.unwrap().length, 3);
      });
      test('404', () async {
        final r = await client.fetchCollection('unicorns');
        expect(r.isSuccessful, isFalse);
        expect(r.statusCode, 404);
        expect(r.errors.first.status, '404');
        expect(r.errors.first.title, 'Collection not found');
        expect(r.errors.first.detail, "Collection 'unicorns' does not exist");
      });
    });

    group('Fetching Related Resources', () {
      test('successful', () async {
        final r = await client.fetchRelatedResource('books', '1', 'publisher');
        expect(r.isSuccessful, isTrue);
        expect(r.statusCode, 200);
        expect(r.data.unwrap().type, 'companies');
        expect(r.data.unwrap().id, '1');
      });

      test('404 on collection', () async {
        final r =
            await client.fetchRelatedResource('unicorns', '1', 'publisher');
        expect(r.isSuccessful, isFalse);
        expect(r.statusCode, 404);
        expect(r.errors.first.status, '404');
        expect(r.errors.first.title, 'Collection not found');
        expect(r.errors.first.detail, "Collection 'unicorns' does not exist");
      });

      test('404 on resource', () async {
        final r = await client.fetchRelatedResource('books', '42', 'publisher');
        expect(r.isSuccessful, isFalse);
        expect(r.statusCode, 404);
        expect(r.errors.first.status, '404');
        expect(r.errors.first.title, 'Resource not found');
        expect(
            r.errors.first.detail, "Resource '42' does not exist in 'books'");
      });

      test('404 on relationship', () async {
        final r = await client.fetchRelatedResource('books', '1', 'owner');
        expect(r.isSuccessful, isFalse);
        expect(r.statusCode, 404);
        expect(r.errors.first.status, '404');
        expect(r.errors.first.title, 'Relationship not found');
        expect(r.errors.first.detail,
            "Relationship 'owner' does not exist in 'books:1'");
      });
    });

    group('Fetching Related Collections', () {
      test('successful', () async {
        final r = await client.fetchRelatedCollection('books', '1', 'authors');
        expect(r.isSuccessful, isTrue);
        expect(r.statusCode, 200);
        expect(r.data.unwrap().length, 2);
        expect(r.data.unwrap().first.attributes['name'], 'Martin Fowler');
      });

      test('404 on collection', () async {
        final r =
            await client.fetchRelatedCollection('unicorns', '1', 'athors');
        expect(r.isSuccessful, isFalse);
        expect(r.statusCode, 404);
        expect(r.errors.first.status, '404');
        expect(r.errors.first.title, 'Collection not found');
        expect(r.errors.first.detail, "Collection 'unicorns' does not exist");
      });

      test('404 on resource', () async {
        final r = await client.fetchRelatedCollection('books', '42', 'authors');
        expect(r.isSuccessful, isFalse);
        expect(r.statusCode, 404);
        expect(r.errors.first.status, '404');
        expect(r.errors.first.title, 'Resource not found');
        expect(
            r.errors.first.detail, "Resource '42' does not exist in 'books'");
      });

      test('404 on relationship', () async {
        final r = await client.fetchRelatedCollection('books', '1', 'readers');
        expect(r.isSuccessful, isFalse);
        expect(r.statusCode, 404);
        expect(r.errors.first.status, '404');
        expect(r.errors.first.title, 'Relationship not found');
        expect(r.errors.first.detail,
            "Relationship 'readers' does not exist in 'books:1'");
      });
    });

    group('Fetching a to-one relationship', () {
      test('successful', () async {
        final r = await client.fetchToOne('books', '1', 'publisher');
        expect(r.isSuccessful, isTrue);
        expect(r.statusCode, 200);
        expect(r.data.unwrap().type, 'companies');
        expect(r.data.unwrap().id, '1');
      });

      test('404 on collection', () async {
        final r = await client.fetchToOne('unicorns', '1', 'publisher');
        expect(r.isSuccessful, isFalse);
        expect(r.statusCode, 404);
        expect(r.errors.first.status, '404');
        expect(r.errors.first.title, 'Collection not found');
        expect(r.errors.first.detail, "Collection 'unicorns' does not exist");
      });

      test('404 on resource', () async {
        final r = await client.fetchToOne('books', '42', 'publisher');
        expect(r.isSuccessful, isFalse);
        expect(r.statusCode, 404);
        expect(r.errors.first.status, '404');
        expect(r.errors.first.title, 'Resource not found');
        expect(
            r.errors.first.detail, "Resource '42' does not exist in 'books'");
      });

      test('404 on relationship', () async {
        final r = await client.fetchToOne('books', '1', 'owner');
        expect(r.isSuccessful, isFalse);
        expect(r.statusCode, 404);
        expect(r.errors.first.status, '404');
        expect(r.errors.first.title, 'Relationship not found');
        expect(r.errors.first.detail,
            "Relationship 'owner' does not exist in 'books:1'");
      });
    });

    group('Fetching a to-many relationship', () {
      test('successful', () async {
        final r = await client.fetchToMany('books', '1', 'authors');
        expect(r.isSuccessful, isTrue);
        expect(r.statusCode, 200);
        expect(r.data.unwrap().length, 2);
        expect(r.data.unwrap().first.type, 'people');
      });

      test('404 on collection', () async {
        final r = await client.fetchToMany('unicorns', '1', 'athors');
        expect(r.isSuccessful, isFalse);
        expect(r.statusCode, 404);
        expect(r.errors.first.status, '404');
        expect(r.errors.first.title, 'Collection not found');
        expect(r.errors.first.detail, "Collection 'unicorns' does not exist");
      });

      test('404 on resource', () async {
        final r = await client.fetchToMany('books', '42', 'authors');
        expect(r.isSuccessful, isFalse);
        expect(r.statusCode, 404);
        expect(r.errors.first.status, '404');
        expect(r.errors.first.title, 'Resource not found');
        expect(
            r.errors.first.detail, "Resource '42' does not exist in 'books'");
      });

      test('404 on relationship', () async {
        final r = await client.fetchToMany('books', '1', 'readers');
        expect(r.isSuccessful, isFalse);
        expect(r.statusCode, 404);
        expect(r.errors.first.status, '404');
        expect(r.errors.first.title, 'Relationship not found');
        expect(r.errors.first.detail,
            "Relationship 'readers' does not exist in 'books:1'");
      });
    });

    group('Fetching a generic relationship', () {
      test('successful to-one', () async {
        final r = await client.fetchRelationship('books', '1', 'publisher');
        expect(r.isSuccessful, isTrue);
        expect(r.statusCode, 200);
        final rel = r.data;
        if (rel is ToOne) {
          expect(rel.unwrap().type, 'companies');
          expect(rel.unwrap().id, '1');
        } else {
          fail('Not a ToOne relationship');
        }
      });

      test('successful to-many', () async {
        final r = await client.fetchRelationship('books', '1', 'authors');
        expect(r.isSuccessful, isTrue);
        expect(r.statusCode, 200);
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
        final r = await client.fetchRelationship('unicorns', '1', 'athors');
        expect(r.isSuccessful, isFalse);
        expect(r.statusCode, 404);
        expect(r.errors.first.status, '404');
        expect(r.errors.first.title, 'Collection not found');
        expect(r.errors.first.detail, "Collection 'unicorns' does not exist");
      });

      test('404 on resource', () async {
        final r = await client.fetchRelationship('books', '42', 'authors');
        expect(r.isSuccessful, isFalse);
        expect(r.statusCode, 404);
        expect(r.errors.first.status, '404');
        expect(r.errors.first.title, 'Resource not found');
        expect(
            r.errors.first.detail, "Resource '42' does not exist in 'books'");
      });

      test('404 on relationship', () async {
        final r = await client.fetchRelationship('books', '1', 'readers');
        expect(r.isSuccessful, isFalse);
        expect(r.statusCode, 404);
        expect(r.errors.first.status, '404');
        expect(r.errors.first.title, 'Relationship not found');
        expect(r.errors.first.detail,
            "Relationship 'readers' does not exist in 'books:1'");
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
      test('successfully adding a new identifier', () async {
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

      test('successfully adding an existing identifier', () async {
        final r = await client.addToRelationship(
            'books', '1', 'authors', [Identifier('people', '2')]);
        expect(r.isSuccessful, isTrue);
        expect(r.statusCode, 200);
        expect(r.data.unwrap().length, 2);
        expect(r.data.unwrap().first.id, '1');
        expect(r.data.unwrap().last.id, '2');

        final r1 = await client.fetchResource('books', '1');
        expect(r1.data.unwrap().toMany['authors'].length, 2);
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

    group('Deleting from a to-many relationship', () {
      test('successfully deleting an identifier', () async {
        final r = await client.deleteFromToMany(
            'books', '1', 'authors', [Identifier('people', '1')]);
        expect(r.isSuccessful, isTrue);
        expect(r.statusCode, 200);
        expect(r.data.unwrap().length, 1);
        expect(r.data.unwrap().first.id, '2');

        final r1 = await client.fetchResource('books', '1');
        expect(r1.data.unwrap().toMany['authors'].length, 1);
      });

      test('successfully deleting a non-present identifier', () async {
        final r = await client.deleteFromToMany(
            'books', '1', 'authors', [Identifier('people', '3')]);
        expect(r.isSuccessful, isTrue);
        expect(r.statusCode, 200);
        expect(r.data.unwrap().length, 2);
        expect(r.data.unwrap().first.id, '1');
        expect(r.data.unwrap().last.id, '2');

        final r1 = await client.fetchResource('books', '1');
        expect(r1.data.unwrap().toMany['authors'].length, 2);
      });

      test('404 when collection not found', () async {
        final r = await client.deleteFromToMany(
            'unicorns', '1', 'breed', [Identifier('companies', '1')]);
        expect(r.isSuccessful, isFalse);
        expect(r.statusCode, 404);
        expect(r.data, isNull);
        final error = r.errors.first;
        expect(error.status, '404');
        expect(error.title, 'Collection not found');
        expect(error.detail, "Collection 'unicorns' does not exist");
      });

      test('404 when resource not found', () async {
        final r = await client.deleteFromToMany(
            'books', '42', 'publisher', [Identifier('companies', '1')]);
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

  group('Deleting Resources', () {
    setUp(() async {
      await client.createResource(Resource('apples', '1'));
    });
    test('successful', () async {
      final r = await client.deleteResource('apples', '1');
      expect(r.isSuccessful, isTrue);
      expect(r.statusCode, 204);
      expect(r.data, isNull);

      final r1 = await client.fetchResource('apples', '1');
      expect(r1.isSuccessful, isFalse);
      expect(r1.statusCode, 404);
    });

    test('404 when the collection does not exist', () async {
      final r = await client.deleteResource('unicorns', '42');
      expect(r.isSuccessful, isFalse);
      expect(r.isFailed, isTrue);
      expect(r.statusCode, 404);
      expect(r.data, isNull);
      final error = r.errors.first;
      expect(error.status, '404');
      expect(error.title, 'Collection not found');
      expect(error.detail, "Collection 'unicorns' does not exist");
    });

    test('404 when the resource does not exist', () async {
      final r = await client.deleteResource('books', '42');
      expect(r.isSuccessful, isFalse);
      expect(r.isFailed, isTrue);
      expect(r.statusCode, 404);
      expect(r.data, isNull);
      final error = r.errors.first;
      expect(error.status, '404');
      expect(error.title, 'Resource not found');
      expect(error.detail, "Resource '42' does not exist in 'books'");
    });
  }, testOn: 'vm');
}
