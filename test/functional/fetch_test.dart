import 'dart:io';

import 'package:http/http.dart';
import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:json_api/server.dart';
import 'package:json_api/url_design.dart';
import 'package:shelf/shelf_io.dart';
import 'package:test/test.dart';

import '../../example/server.dart';

void main() async {
  HttpServer server;
  Client httpClient;
  JsonApiClient client;
  final host = 'localhost';
  final port = 8081;
  final urlDesign =
      PathBasedUrlDesign(Uri(scheme: 'http', host: host, port: port));

  void seedData() async {
    final fowler =
        Resource('people', '1', attributes: {'name': 'Martin Fowler'});
    final beck = Resource('people', '2', attributes: {'name': 'Kent Beck'});
    final martin =
        Resource('people', '3', attributes: {'name': 'Robert C. Matin'});
    final norton =
        Resource('people', '4', attributes: {'name': 'Peter Norton'});
    final microsoft =
        Resource('companies', '1', attributes: {'name': 'Microsoft Press'});
    final addison = Resource('companies', '2',
        attributes: {'name': 'Addison-Wesley Professional'});
    final ibmGuide = Resource('books', '1', attributes: {
      'title': "The Peter Norton Programmer's Guide to the IBM PC"
    }, toMany: {
      'authors': [Identifier.of(norton)]
    }, toOne: {
      'publisher': Identifier.of(microsoft)
    });
    final refactoring = Resource('books', '2', attributes: {
      'title': 'Refactoring'
    }, toMany: {
      'authors': [Identifier.of(fowler), Identifier.of(beck)]
    }, toOne: {
      'publisher': Identifier.of(addison)
    });

    final incomplete = Resource('books', '10',
        attributes: {'title': 'Incomplete book'},
        toMany: {'authors': []},
        toOne: {'publisher': null});

    await for (final r in Stream.fromIterable([
      fowler,
      beck,
      martin,
      norton,
      microsoft,
      ibmGuide,
      refactoring,
      incomplete
    ])) {
      await client.createResource(urlDesign.collection(r.type), r);
    }
  }

  setUp(() async {
    httpClient = Client();
    client = JsonApiClient(httpClient);
    final handler = createHttpHandler(
        ShelfRequestResponseConverter(), CRUDController(), urlDesign);

    server = await serve(handler, host, port);
    await seedData();
  });

  tearDown(() async {
    httpClient.close();
    await server.close();
  });

  group('collection', () {
    /// https://jsonapi.org/format/#fetching-resources-responses
    ///
    /// A server MUST respond to a successful request to fetch a
    /// resource collection with an array of resource objects or an
    /// empty array ([]) as the response document’s primary data.
    test('empty primary collection', () async {
      final r0 = await client.fetchCollection(urlDesign.collection('unicorns'));

      expect(r0.status, 200);
      expect(r0.isSuccessful, true);
      expect(r0.document.data.collection.length, 0);
    });

    test('non-empty primary collection', () async {
      final r0 = await client.fetchCollection(urlDesign.collection('people'));

      expect(r0.status, 200);
      expect(r0.isSuccessful, true);
      expect(r0.document.data.collection.length, 4);
    });

    test('empty related collection', () async {
      final r0 = await client
          .fetchCollection(urlDesign.related('books', '10', 'authors'));

      expect(r0.status, 200);
      expect(r0.isSuccessful, true);
      expect(r0.document.data.collection.length, 0);
    });

    test('non-empty related collection', () async {
      final r0 = await client
          .fetchCollection(urlDesign.related('books', '2', 'authors'));

      expect(r0.status, 200);
      expect(r0.isSuccessful, true);
      expect(r0.document.data.collection.length, 2);
      expect(r0.document.data.collection.first.attributes['name'],
          'Martin Fowler');
      expect(r0.document.data.collection.last.attributes['name'], 'Kent Beck');
    });
  }, testOn: 'vm');

  group('resource', () {
    /// A server MUST respond to a successful request to fetch an
    /// individual resource or resource collection with a 200 OK response.
    test('primary resource', () async {
      final r0 = await client.fetchResource(urlDesign.resource('people', '1'));
      expect(r0.status, 200);
      expect(r0.isSuccessful, true);
      expect(r0.document.data.unwrap().attributes['name'], 'Martin Fowler');
      expect(r0.document.data.unwrap().type, 'people');
    });

    test('primary resource not found', () async {
      final r0 =
          await client.fetchResource(urlDesign.resource('unicorns', '555'));
      expect(r0.status, 404);
      expect(r0.isSuccessful, false);
      expect(r0.document.errors.first.detail, 'Resource not found');
    });

    test('related resource', () async {
      final r0 = await client
          .fetchResource(urlDesign.related('books', '1', 'publisher'));
      expect(r0.status, 200);
      expect(r0.isSuccessful, true);
      expect(r0.document.data.unwrap().attributes['name'], 'Microsoft Press');
      expect(r0.document.data.unwrap().type, 'companies');
    });

    test('null related resource', () async {
      final r0 = await client
          .fetchResource(urlDesign.related('books', '10', 'publisher'));
      expect(r0.status, 200);
      expect(r0.isSuccessful, true);
      expect(r0.document.data.unwrap(), null);
    });

    test('related resource not found (primary resouce not found)', () async {
      final r0 = await client
          .fetchResource(urlDesign.related('unicorns', '1', 'owner'));
      expect(r0.status, 404);
      expect(r0.isSuccessful, false);
      expect(r0.document.errors.first.detail, 'Resource not found');
    });

    test('related resource not found (relationship not found)', () async {
      final r0 = await client
          .fetchResource(urlDesign.related('people', '1', 'unicorn'));
      expect(r0.status, 404);
      expect(r0.isSuccessful, false);
      expect(r0.document.errors.first.detail, 'Relatioship not found');
    });
  }, testOn: 'vm');

//  group('collection', () {
//    test('resource collection', () async {
//      final uri = url.collection('companies');
//      final r = await client.fetchCollection(uri);
//      expect(r.status, 200);
//      expect(r.isSuccessful, true);
//      final resObj = r.data.collection.first;
//      expect(resObj.attributes['name'], 'Tesla');
//      expect(resObj.self.uri, url.resource('companies', '1'));
//      expect(resObj.relationships['hq'].related.uri,
//          url.related('companies', '1', 'hq'));
//      expect(resObj.relationships['hq'].self.uri,
//          url.relationship('companies', '1', 'hq'));
//      expect(r.data.self.uri, uri);
//    });
//
//    test('resource collection traversal', () async {
//      final uri =
//          url.collection('companies').replace(queryParameters: {'foo': 'bar'});
//
//      final r0 = await client.fetchCollection(uri);
//      final somePage = r0.data;
//
//      expect(somePage.next.uri.queryParameters['foo'], 'bar',
//          reason: 'query parameters must be preserved');
//
//      final r1 = await client.fetchCollection(somePage.next.uri);
//      final secondPage = r1.data;
//      expect(secondPage.collection.first.attributes['name'], 'BMW');
//      expect(secondPage.self.uri, somePage.next.uri);
//
//      expect(secondPage.last.uri.queryParameters['foo'], 'bar',
//          reason: 'query parameters must be preserved');
//
//      final r2 = await client.fetchCollection(secondPage.last.uri);
//      final lastPage = r2.data;
//      expect(lastPage.collection.first.attributes['name'], 'Toyota');
//      expect(lastPage.self.uri, secondPage.last.uri);
//
//      expect(lastPage.prev.uri.queryParameters['foo'], 'bar',
//          reason: 'query parameters must be preserved');
//
//      final r3 = await client.fetchCollection(lastPage.prev.uri);
//      final secondToLastPage = r3.data;
//      expect(secondToLastPage.collection.first.attributes['name'], 'Audi');
//      expect(secondToLastPage.self.uri, lastPage.prev.uri);
//
//      expect(secondToLastPage.first.uri.queryParameters['foo'], 'bar',
//          reason: 'query parameters must be preserved');
//
//      final r4 = await client.fetchCollection(secondToLastPage.first.uri);
//      final firstPage = r4.data;
//      expect(firstPage.collection.first.attributes['name'], 'Tesla');
//      expect(firstPage.self.uri, secondToLastPage.first.uri);
//    });
//
//    test('related collection', () async {
//      final uri = url.related('companies', '1', 'models');
//      final r = await client.fetchCollection(uri);
//      expect(r.status, 200);
//      expect(r.isSuccessful, true);
//      expect(r.data.collection.first.attributes['name'], 'Roadster');
//      expect(r.data.self.uri, uri);
//    });
//
//    test('related collection traversal', () async {
//      final uri = url.related('companies', '1', 'models');
//      final r0 = await client.fetchCollection(uri);
//      final firstPage = r0.data;
//      expect(firstPage.collection.length, 1);
//
//      final r1 = await client.fetchCollection(firstPage.last.uri);
//      final lastPage = r1.data;
//      expect(lastPage.collection.length, 1);
//    });
//
//    test('404', () async {
//      final r = await client.fetchCollection(url.collection('unicorns'));
//      expect(r.status, 404);
//      expect(r.isSuccessful, false);
//      expect(r.document.errors.first.detail, 'Unknown resource type unicorns');
//    });
//  }, testOn: 'vm');
//
//  group('single resource', () {
//    test('single resource', () async {
//      final uri = url.resource('models', '1');
//      final r = await client.fetchResource(uri);
//      expect(r.status, 200);
//      expect(r.isSuccessful, true);
//      expect(r.data.unwrap().attributes['name'], 'Roadster');
//      expect(r.data.self.uri, uri);
//    });
//
//    test('404 on type', () async {
//      final r = await client.fetchResource(url.resource('unicorns', '1'));
//      expect(r.status, 404);
//      expect(r.isSuccessful, false);
//    });
//
//    test('404 on id', () async {
//      final r = await client.fetchResource(url.resource('models', '555'));
//      expect(r.status, 404);
//      expect(r.isSuccessful, false);
//    });
//  }, testOn: 'vm');
//
//  group('related resource', () {
//    test('related resource', () async {
//      final uri = url.related('companies', '1', 'hq');
//      final r = await client.fetchResource(uri);
//      expect(r.status, 200);
//      expect(r.isSuccessful, true);
//      expect(r.data.unwrap().attributes['name'], 'Palo Alto');
//      expect(r.data.self.uri, uri);
//    });
//
//    test('404 on type', () async {
//      final r = await client.fetchResource(url.related('unicorns', '1', 'hq'));
//      expect(r.status, 404);
//      expect(r.isSuccessful, false);
//    });
//
//    test('404 on id', () async {
//      final r = await client.fetchResource(url.related('models', '555', 'hq'));
//      expect(r.status, 404);
//      expect(r.isSuccessful, false);
//    });
//
//    test('404 on relationship', () async {
//      final r =
//          await client.fetchResource(url.related('companies', '1', 'unicorn'));
//      expect(r.status, 404);
//      expect(r.isSuccessful, false);
//    });
//  }, testOn: 'vm');
//
//  group('relationships', () {
//    test('to-one', () async {
//      final uri = url.relationship('companies', '1', 'hq');
//      final r = await client.fetchToOne(uri);
//      expect(r.status, 200);
//      expect(r.isSuccessful, true);
//      expect(r.data.unwrap().type, 'cities');
//      expect(r.data.self.uri, uri);
//      expect(r.data.related.uri.toString(),
//          'http://localhost:$port/companies/1/hq');
//    });
//
//    test('empty to-one', () async {
//      final uri = url.relationship('companies', '3', 'hq');
//      final r = await client.fetchToOne(uri);
//      expect(r.status, 200);
//      expect(r.isSuccessful, true);
//      expect(r.data.unwrap(), isNull);
//      expect(r.data.self.uri, uri);
//      expect(r.data.related.uri, url.related('companies', '3', 'hq'));
//    });
//
//    test('generic to-one', () async {
//      final uri = url.relationship('companies', '1', 'hq');
//      final r = await client.fetchRelationship(uri);
//      expect(r.status, 200);
//      expect(r.isSuccessful, true);
//      expect(r.data, TypeMatcher<ToOne>());
//      expect((r.data as ToOne).unwrap().type, 'cities');
//      expect(r.data.self.uri, uri);
//      expect(r.data.related.uri, url.related('companies', '1', 'hq'));
//    });
//
//    test('to-many', () async {
//      final uri = url.relationship('companies', '1', 'models');
//      final r = await client.fetchToMany(uri);
//      expect(r.status, 200);
//      expect(r.isSuccessful, true);
//      expect(r.data.identifiers.first.type, 'models');
//      expect(r.data.self.uri, uri);
//      expect(r.data.related.uri, url.related('companies', '1', 'models'));
//    });
//
//    test('empty to-many', () async {
//      final uri = url.relationship('companies', '3', 'models');
//      final r = await client.fetchToMany(uri);
//      expect(r.status, 200);
//      expect(r.isSuccessful, true);
//      expect(r.data.identifiers, isEmpty);
//      expect(r.data.self.uri, uri);
//      expect(r.data.related.uri, url.related('companies', '3', 'models'));
//    });
//
//    test('generic to-many', () async {
//      final uri = url.relationship('companies', '1', 'models');
//      final r = await client.fetchRelationship(uri);
//      expect(r.status, 200);
//      expect(r.isSuccessful, true);
//      expect(r.data, TypeMatcher<ToMany>());
//      expect((r.data as ToMany).identifiers.first.type, 'models');
//      expect(r.data.self.uri, uri);
//      expect(r.data.related.uri, url.related('companies', '1', 'models'));
//    });
//  }, testOn: 'vm');
//
//  group('compound document', () {
//    test('single resource compound document', () async {
//      final uri = url.resource('companies', '1');
//      final r =
//          await client.fetchResource(uri, parameters: Include(['models']));
//      expect(r.status, 200);
//      expect(r.isSuccessful, true);
//      expect(r.data.unwrap().attributes['name'], 'Tesla');
//      expect(r.data.included.length, 4);
//      expect(r.data.included.last.type, 'models');
//      expect(r.data.included.last.attributes['name'], 'Model 3');
//    });
//
//    test('"included" member should not present if not requested', () async {
//      final uri = url.resource('companies', '1');
//      final r = await client.fetchResource(uri);
//      expect(r.status, 200);
//      expect(r.isSuccessful, true);
//      expect(r.data.unwrap().attributes['name'], 'Tesla');
//      expect(r.data.included, null);
//    });
//  }, testOn: 'vm');
}
