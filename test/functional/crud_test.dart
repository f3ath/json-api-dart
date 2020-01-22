import 'dart:io';

import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:json_api/server.dart';
import 'package:json_api/uri_design.dart';
import 'package:shelf/shelf_io.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../../example/server/controller/crud_controller.dart';
import '../../example/server/shelf_request_response_converter.dart';

/// Basic CRUD operations
void main() async {
  HttpServer server;
  UriAwareClient client;
  final host = 'localhost';
  final port = 8081;
  final base = Uri(scheme: 'http', host: host, port: port);
  final design = UriDesign.standard(base);
  final people = [
    'Erich Gamma',
    'Richard Helm',
    'Ralph Johnson',
    'John Vlissides',
  ]
      .map((name) => name.split(' '))
      .map((name) => Resource('people', Uuid().v4(),
          attributes: {'firstName': name.first, 'lastName': name.last}))
      .toList();

  final publisher = Resource('companies', Uuid().v4(),
      attributes: {'name': 'Addison-Wesley'});

  final book = Resource('books', Uuid().v4(),
      attributes: {'title': 'Design Patterns'},
      toOne: {'publisher': Identifier.of(publisher)},
      toMany: {'authors': people.map(Identifier.of).toList()});

  setUp(() async {
    client = UriAwareClient(design);
    final handler = RequestHandler(
        ShelfRequestResponseConverter(),
        CRUDController(
            Uuid().v4, const ['people', 'books', 'companies'].contains),
        design);

    server = await serve(handler, host, port);

    await for (final resource
        in Stream.fromIterable([...people, publisher, book])) {
      await client.createResource(resource);
    }
  });

  tearDown(() async {
    client.close();
    await server.close();
  });

  group('Fetch', () {
    test('a primary resource', () async {
      final r = await client.fetchResource(book.type, book.id);
      expect(r.status, 200);
      expect(r.isSuccessful, isTrue);
      expect(r.data.unwrap().attributes['title'], 'Design Patterns');
      expect(r.data.unwrap().toOne['publisher'].type, publisher.type);
      expect(r.data.unwrap().toOne['publisher'].id, publisher.id);
      expect(r.data.unwrap().toMany['authors'].length, 4);
      expect(r.data.unwrap().toMany['authors'].first.type, 'people');
      expect(r.data.unwrap().toMany['authors'].last.type, 'people');
    });

    test('a non-existing primary resource', () async {
      final r = await client.fetchResource('books', '1');
      expect(r.status, 404);
      expect(r.isSuccessful, isFalse);
      expect(r.document.errors.first.detail, 'Resource not found');
    });

    test('a primary collection', () async {
      final r = await client.fetchCollection('people');
      expect(r.status, 200);
      expect(r.isSuccessful, isTrue);
      expect(r.data.unwrap().length, 4);
      expect(r.data.unwrap().first.attributes['firstName'], 'Erich');
      expect(r.data.unwrap().first.attributes['lastName'], 'Gamma');
    });

    test('a non-existing primary collection', () async {
      final r = await client.fetchCollection('unicorns');
      expect(r.status, 404);
      expect(r.isSuccessful, isFalse);
      expect(r.document.errors.first.detail, 'Collection not found');
    });

    test('a related resource', () async {
      final r =
          await client.fetchRelatedResource(book.type, book.id, 'publisher');
      expect(r.status, 200);
      expect(r.isSuccessful, isTrue);
      expect(r.data.unwrap().attributes['name'], 'Addison-Wesley');
    });

    test('a related collection', () async {
      final r =
          await client.fetchRelatedCollection(book.type, book.id, 'authors');
      expect(r.status, 200);
      expect(r.isSuccessful, isTrue);
      expect(r.data.unwrap().length, 4);
      expect(r.data.unwrap().first.attributes['firstName'], 'Erich');
      expect(r.data.unwrap().first.attributes['lastName'], 'Gamma');
    });

    test('a to-one relationship', () async {
      final r = await client.fetchToOne(book.type, book.id, 'publisher');
      expect(r.status, 200);
      expect(r.isSuccessful, isTrue);
      expect(r.data.unwrap().type, publisher.type);
      expect(r.data.unwrap().id, publisher.id);
    });

    test('a generic to-one relationship', () async {
      final r = await client.fetchRelationship(book.type, book.id, 'publisher');
      expect(r.status, 200);
      expect(r.isSuccessful, isTrue);

      final data = r.data;
      if (data is ToOne) {
        expect(data.unwrap().type, publisher.type);
        expect(data.unwrap().id, publisher.id);
      } else {
        fail('data is not ToOne');
      }
    });

    test('a to-many relationship', () async {
      final r = await client.fetchToMany(book.type, book.id, 'authors');
      expect(r.status, 200);
      expect(r.isSuccessful, isTrue);
      expect(r.data.unwrap().length, 4);
      expect(r.data.unwrap().first.type, people.first.type);
      expect(r.data.unwrap().first.id, people.first.id);
    });

    test('a generic to-many relationship', () async {
      final r = await client.fetchRelationship(book.type, book.id, 'authors');
      expect(r.status, 200);
      expect(r.isSuccessful, isTrue);
      final data = r.data;
      if (data is ToMany) {
        expect(data.unwrap().length, 4);
        expect(data.unwrap().first.type, people.first.type);
        expect(data.unwrap().first.id, people.first.id);
      } else {
        fail('data is not ToMany');
      }
    });
  }, testOn: 'vm');

  group('Delete', () {
    test('a primary resource', () async {
      await client.deleteResource(book.type, book.id);

      final r = await client.fetchResource(book.type, book.id);
      expect(r.status, 404);
      expect(r.isSuccessful, isFalse);
      expect(r.isFailed, isTrue);
    });

    test('a to-one relationship', () async {
      await client.deleteToOne(book.type, book.id, 'publisher');

      final r = await client.fetchResource(book.type, book.id);
      expect(r.isSuccessful, isTrue);
      expect(r.data.unwrap().toOne['publisher'], isNull);
    });

    test('in a to-many relationship', () async {
      await client.deleteFromToMany(
          book.type, book.id, 'authors', people.take(2).map(Identifier.of));

      final r = await client.fetchToMany(book.type, book.id, 'authors');
      expect(r.isSuccessful, isTrue);
      expect(r.data.unwrap().length, 2);
      expect(r.data.unwrap().last.id, people.last.id);
    });
  }, testOn: 'vm');

  group('Create', () {
    test('a primary resource, id assigned on the server', () async {
      final book = Resource('books', null,
          attributes: {'title': 'The Lord of the Rings'});
      final r0 = await client.createResource(book);
      expect(r0.status, 201);
      final r1 = await JsonApiClient().fetchResource(r0.location);
      expect(r1.data.unwrap().attributes, equals(book.attributes));
      expect(r1.data.unwrap().type, equals(book.type));
    });
  }, testOn: 'vm');

  group('Update', () {
    test('a primary resource', () async {
      await client.updateResource(book.replace(attributes: {'pageCount': 416}));

      final r = await client.fetchResource(book.type, book.id);
      expect(r.status, 200);
      expect(r.isSuccessful, isTrue);
      expect(r.data.unwrap().attributes['pageCount'], 416);
    });

    test('to-one relationship', () async {
      await client.replaceToOne(
          book.type, book.id, 'publisher', Identifier('companies', '100'));

      final r = await client.fetchResource(book.type, book.id);
      expect(r.isSuccessful, isTrue);
      expect(r.data.unwrap().toOne['publisher'].id, '100');
    });

    test('a to-many relationship by adding more identifiers', () async {
      await client.addToRelationship(
          book.type, book.id, 'authors', [Identifier('people', '100')]);

      final r = await client.fetchToMany(book.type, book.id, 'authors');
      expect(r.isSuccessful, isTrue);
      expect(r.data.unwrap().length, 5);
      expect(r.data.unwrap().last.id, '100');
    });

    test('a to-many relationship by replacing', () async {
      await client.replaceToMany(
          book.type, book.id, 'authors', [Identifier('people', '100')]);

      final r = await client.fetchToMany(book.type, book.id, 'authors');
      expect(r.isSuccessful, isTrue);
      expect(r.data.unwrap().length, 1);
      expect(r.data.unwrap().first.id, '100');
    });
  }, testOn: 'vm');
}
