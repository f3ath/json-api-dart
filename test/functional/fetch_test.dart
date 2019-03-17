@TestOn('vm')
import 'dart:io';

import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:test/test.dart';

import '../../example/cars_server.dart';

void main() async {
  HttpServer server;
  final client = JsonApiClient();
  setUp(() async {
    server = await createServer(InternetAddress.loopbackIPv4, 8080);
  });

  tearDown(() async => await server.close());

  group('collection', () {
    test('resource collection', () async {
      final uri = Url.collection('companies');
      final r = await client.fetchCollection(uri);
      expect(r.status, 200);
      expect(r.isSuccessful, true);
      expect(r.data.collection.first.attributes['name'], 'Tesla');
      expect(r.data.self.uri, uri);
    });

    test('resource collection traversal', () async {
      final uri = Url.collection('companies');

      final r0 = await client.fetchCollection(uri);
      final somePage = r0.data;

      final r1 = await client.fetchCollection(somePage.pagination.next.uri);
      final secondPage = r1.data;
      expect(secondPage.collection.first.attributes['name'], 'BMW');
      expect(secondPage.self.uri, somePage.pagination.next.uri);

      final r2 = await client.fetchCollection(secondPage.pagination.last.uri);
      final lastPage = r2.data;
      expect(lastPage.collection.first.attributes['name'], 'Toyota');
      expect(lastPage.self.uri, secondPage.pagination.last.uri);

      final r3 = await client.fetchCollection(lastPage.pagination.prev.uri);
      final secondToLastPage = r3.data;
      expect(secondToLastPage.collection.first.attributes['name'], 'Audi');
      expect(secondToLastPage.self.uri, lastPage.pagination.prev.uri);

      final r4 =
          await client.fetchCollection(secondToLastPage.pagination.first.uri);
      final firstPage = r4.data;
      expect(firstPage.collection.first.attributes['name'], 'Tesla');
      expect(firstPage.self.uri, secondToLastPage.pagination.first.uri);
    });

    test('related collection', () async {
      final uri = Url.related('companies', '1', 'models');
      final r = await client.fetchCollection(uri);
      expect(r.status, 200);
      expect(r.isSuccessful, true);
      expect(r.data.collection.first.attributes['name'], 'Roadster');
      expect(r.data.self.uri, uri);
    });

    test('404', () async {
      final r = await client.fetchCollection(Url.collection('unicorns'));
      expect(r.status, 404);
      expect(r.isSuccessful, false);
      expect(r.document.errors.first.detail, 'Unknown resource type');
    });
  });

  group('single resource', () {
    test('single resource', () async {
      final uri = Url.resource('models', '1');
      final r = await client.fetchResource(uri);
      expect(r.status, 200);
      expect(r.isSuccessful, true);
      expect(r.data.toResource().attributes['name'], 'Roadster');
      expect(r.data.self.uri, uri);
    });

    test('single resource compound document', () async {
      final uri = Url.resource('companies', '1');
      final r = await client.fetchResource(uri);
      expect(r.status, 200);
      expect(r.isSuccessful, true);
      expect(r.data.toResource().attributes['name'], 'Tesla');
      expect(r.data.self.uri, uri);
      expect(r.document.included.length, 5);
      expect(r.document.included.first.type, 'cities');
      expect(r.document.included.first.attributes['name'], 'Palo Alto');
      expect(r.document.included.last.type, 'models');
      expect(r.document.included.last.attributes['name'], 'Model 3');

    });

    test('404 on type', () async {
      final r = await client.fetchResource(Url.resource('unicorns', '1'));
      expect(r.status, 404);
      expect(r.isSuccessful, false);
    });

    test('404 on id', () async {
      final r = await client.fetchResource(Url.resource('models', '555'));
      expect(r.status, 404);
      expect(r.isSuccessful, false);
    });
  });

  group('related resource', () {
    test('related resource', () async {
      final uri = Url.related('companies', '1', 'hq');
      final r = await client.fetchResource(uri);
      expect(r.status, 200);
      expect(r.isSuccessful, true);
      expect(r.data.toResource().attributes['name'], 'Palo Alto');
      expect(r.data.self.uri, uri);
    });

    test('404 on type', () async {
      final r = await client.fetchResource(Url.related('unicorns', '1', 'hq'));
      expect(r.status, 404);
      expect(r.isSuccessful, false);
    });

    test('404 on id', () async {
      final r = await client.fetchResource(Url.related('models', '555', 'hq'));
      expect(r.status, 404);
      expect(r.isSuccessful, false);
    });

    test('404 on relationship', () async {
      final r =
          await client.fetchResource(Url.related('companies', '1', 'unicorn'));
      expect(r.status, 404);
      expect(r.isSuccessful, false);
    });
  });

  group('relationships', () {
    test('to-one', () async {
      final uri = Url.relationship('companies', '1', 'hq');
      final r = await client.fetchToOne(uri);
      expect(r.status, 200);
      expect(r.isSuccessful, true);
      expect(r.data.toIdentifier().type, 'cities');
      expect(r.data.self.uri, uri);
      expect(r.data.related.uri.toString(),
          'http://localhost:8080/companies/1/hq');
    });

    test('empty to-one', () async {
      final uri = Url.relationship('companies', '3', 'hq');
      final r = await client.fetchToOne(uri);
      expect(r.status, 200);
      expect(r.isSuccessful, true);
      expect(r.data.toIdentifier(), isNull);
      expect(r.data.self.uri, uri);
      expect(r.data.related.uri.toString(),
          'http://localhost:8080/companies/3/hq');
    });

    test('generic to-one', () async {
      final uri = Url.relationship('companies', '1', 'hq');
      final r = await client.fetchRelationship(uri);
      expect(r.status, 200);
      expect(r.isSuccessful, true);
      expect(r.data, TypeMatcher<ToOne>());
      expect((r.data as ToOne).toIdentifier().type, 'cities');
      expect(r.data.self.uri, uri);
      expect(r.data.related.uri.toString(),
          'http://localhost:8080/companies/1/hq');
    });

    test('to-many', () async {
      final uri = Url.relationship('companies', '1', 'models');
      final r = await client.fetchToMany(uri);
      expect(r.status, 200);
      expect(r.isSuccessful, true);
      expect(r.data.identifiers.first.type, 'models');
      expect(r.data.self.uri, uri);
      expect(r.data.related.uri.toString(),
          'http://localhost:8080/companies/1/models');
    });

    test('empty to-many', () async {
      final uri = Url.relationship('companies', '3', 'models');
      final r = await client.fetchToMany(uri);
      expect(r.status, 200);
      expect(r.isSuccessful, true);
      expect(r.data.identifiers, isEmpty);
      expect(r.data.self.uri, uri);
      expect(r.data.related.uri.toString(),
          'http://localhost:8080/companies/3/models');
    });

    test('generic to-many', () async {
      final uri = Url.relationship('companies', '1', 'models');
      final r = await client.fetchRelationship(uri);
      expect(r.status, 200);
      expect(r.isSuccessful, true);
      expect(r.data, TypeMatcher<ToMany>());
      expect((r.data as ToMany).identifiers.first.type, 'models');
      expect(r.data.self.uri, uri);
      expect(r.data.related.uri.toString(),
          'http://localhost:8080/companies/1/models');
    });
  });
}
