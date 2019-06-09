import 'dart:io';

import 'package:json_api/json_api.dart';
import 'package:json_api/src/server/_server.dart';
import 'package:test/test.dart';

import '../../example/cars_server.dart';

void main() async {
  HttpServer server;
  final client = JsonApiClient();
  final port = 8083;
  final route = Routing(Uri.parse('http://localhost:$port'));
  setUp(() async {
    server = await createServer(InternetAddress.loopbackIPv4, port);
  });

  tearDown(() async => await server.close());

  group('collection', () {
    test('resource collection', () async {
      final uri = route.collection('companies');
      final r = await client.fetchCollection(uri);
      expect(r.status, 200);
      expect(r.isSuccessful, true);
      final resObj = r.data.collection.first;
      expect(resObj.attributes['name'], 'Tesla');
      expect(resObj.self.uri.toString(), 'http://localhost:$port/companies/1');
      expect(resObj.relationships['hq'].related.uri.toString(),
          'http://localhost:$port/companies/1/hq');
      expect(resObj.relationships['hq'].self.uri.toString(),
          'http://localhost:$port/companies/1/relationships/hq');
      expect(r.data.self.uri, uri);
    });

    test('resource collection traversal', () async {
      final uri = route
          .collection('companies')
          .replace(queryParameters: {'foo': 'bar'});

      final r0 = await client.fetchCollection(uri);
      final somePage = r0.data;

      expect(somePage.pagination.next.uri.queryParameters['foo'], 'bar',
          reason: 'query parameters must be preserved');

      final r1 = await client.fetchCollection(somePage.pagination.next.uri);
      final secondPage = r1.data;
      expect(secondPage.collection.first.attributes['name'], 'BMW');
      expect(secondPage.self.uri, somePage.pagination.next.uri);

      expect(secondPage.pagination.last.uri.queryParameters['foo'], 'bar',
          reason: 'query parameters must be preserved');

      final r2 = await client.fetchCollection(secondPage.pagination.last.uri);
      final lastPage = r2.data;
      expect(lastPage.collection.first.attributes['name'], 'Toyota');
      expect(lastPage.self.uri, secondPage.pagination.last.uri);

      expect(lastPage.pagination.prev.uri.queryParameters['foo'], 'bar',
          reason: 'query parameters must be preserved');

      final r3 = await client.fetchCollection(lastPage.pagination.prev.uri);
      final secondToLastPage = r3.data;
      expect(secondToLastPage.collection.first.attributes['name'], 'Audi');
      expect(secondToLastPage.self.uri, lastPage.pagination.prev.uri);

      expect(
          secondToLastPage.pagination.first.uri.queryParameters['foo'], 'bar',
          reason: 'query parameters must be preserved');

      final r4 =
          await client.fetchCollection(secondToLastPage.pagination.first.uri);
      final firstPage = r4.data;
      expect(firstPage.collection.first.attributes['name'], 'Tesla');
      expect(firstPage.self.uri, secondToLastPage.pagination.first.uri);
    });

    test('related collection', () async {
      final uri = route.related('companies', '1', 'models');
      final r = await client.fetchCollection(uri);
      expect(r.status, 200);
      expect(r.isSuccessful, true);
      expect(r.data.collection.first.attributes['name'], 'Roadster');
      expect(r.data.self.uri, uri);
    });

    test('related collection travesal', () async {
      final uri = route.related('companies', '1', 'models');
      final r0 = await client.fetchCollection(uri);
      final firstPage = r0.data;
      expect(firstPage.collection.length, 1);

      final r1 = await client.fetchCollection(firstPage.pagination.last.uri);
      final lastPage = r1.data;
      expect(lastPage.collection.length, 1);
    });

    test('404', () async {
      final r = await client.fetchCollection(route.collection('unicorns'));
      expect(r.status, 404);
      expect(r.isSuccessful, false);
      expect(r.document.errors.first.detail, 'Unknown resource type');
    });
  }, testOn: 'vm');

  group('single resource', () {
    test('single resource', () async {
      final uri = route.resource('models', '1');
      final r = await client.fetchResource(uri);
      expect(r.status, 200);
      expect(r.isSuccessful, true);
      expect(r.data.unwrap().attributes['name'], 'Roadster');
      expect(r.data.self.uri, uri);
    });

    test('single resource compound document', () async {
      final uri = route.resource('companies', '1');
      final r = await client.fetchResource(uri);
      expect(r.status, 200);
      expect(r.isSuccessful, true);
      expect(r.data.unwrap().attributes['name'], 'Tesla');
      expect(r.data.self.uri, uri);
      expect(r.data.included.length, 5);
      expect(r.data.included.first.type, 'cities');
      expect(r.data.included.first.attributes['name'], 'Palo Alto');
      expect(r.data.included.last.type, 'models');
      expect(r.data.included.last.attributes['name'], 'Model 3');
    });

    test('404 on type', () async {
      final r = await client.fetchResource(route.resource('unicorns', '1'));
      expect(r.status, 404);
      expect(r.isSuccessful, false);
    });

    test('404 on id', () async {
      final r = await client.fetchResource(route.resource('models', '555'));
      expect(r.status, 404);
      expect(r.isSuccessful, false);
    });
  }, testOn: 'vm');

  group('related resource', () {
    test('related resource', () async {
      final uri = route.related('companies', '1', 'hq');
      final r = await client.fetchResource(uri);
      expect(r.status, 200);
      expect(r.isSuccessful, true);
      expect(r.data.unwrap().attributes['name'], 'Palo Alto');
      expect(r.data.self.uri, uri);
    });

    test('404 on type', () async {
      final r =
          await client.fetchResource(route.related('unicorns', '1', 'hq'));
      expect(r.status, 404);
      expect(r.isSuccessful, false);
    });

    test('404 on id', () async {
      final r =
          await client.fetchResource(route.related('models', '555', 'hq'));
      expect(r.status, 404);
      expect(r.isSuccessful, false);
    });

    test('404 on relationship', () async {
      final r = await client
          .fetchResource(route.related('companies', '1', 'unicorn'));
      expect(r.status, 404);
      expect(r.isSuccessful, false);
    });
  }, testOn: 'vm');

  group('relationships', () {
    test('to-one', () async {
      final uri = route.relationship('companies', '1', 'hq');
      final r = await client.fetchToOne(uri);
      expect(r.status, 200);
      expect(r.isSuccessful, true);
      expect(r.data.unwrap().type, 'cities');
      expect(r.data.self.uri, uri);
      expect(r.data.related.uri.toString(),
          'http://localhost:$port/companies/1/hq');
    });

    test('empty to-one', () async {
      final uri = route.relationship('companies', '3', 'hq');
      final r = await client.fetchToOne(uri);
      expect(r.status, 200);
      expect(r.isSuccessful, true);
      expect(r.data.unwrap(), isNull);
      expect(r.data.self.uri, uri);
      expect(r.data.related.uri.toString(),
          'http://localhost:$port/companies/3/hq');
    });

    test('generic to-one', () async {
      final uri = route.relationship('companies', '1', 'hq');
      final r = await client.fetchRelationship(uri);
      expect(r.status, 200);
      expect(r.isSuccessful, true);
      expect(r.data, TypeMatcher<ToOne>());
      expect((r.data as ToOne).unwrap().type, 'cities');
      expect(r.data.self.uri, uri);
      expect(r.data.related.uri.toString(),
          'http://localhost:$port/companies/1/hq');
    });

    test('to-many', () async {
      final uri = route.relationship('companies', '1', 'models');
      final r = await client.fetchToMany(uri);
      expect(r.status, 200);
      expect(r.isSuccessful, true);
      expect(r.data.identifiers.first.type, 'models');
      expect(r.data.self.uri, uri);
      expect(r.data.related.uri.toString(),
          'http://localhost:$port/companies/1/models');
    });

    test('empty to-many', () async {
      final uri = route.relationship('companies', '3', 'models');
      final r = await client.fetchToMany(uri);
      expect(r.status, 200);
      expect(r.isSuccessful, true);
      expect(r.data.identifiers, isEmpty);
      expect(r.data.self.uri, uri);
      expect(r.data.related.uri.toString(),
          'http://localhost:$port/companies/3/models');
    });

    test('generic to-many', () async {
      final uri = route.relationship('companies', '1', 'models');
      final r = await client.fetchRelationship(uri);
      expect(r.status, 200);
      expect(r.isSuccessful, true);
      expect(r.data, TypeMatcher<ToMany>());
      expect((r.data as ToMany).identifiers.first.type, 'models');
      expect(r.data.self.uri, uri);
      expect(r.data.related.uri.toString(),
          'http://localhost:$port/companies/1/models');
    });
  }, testOn: 'vm');
}
