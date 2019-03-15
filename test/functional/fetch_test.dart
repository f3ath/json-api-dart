@TestOn('vm')
import 'dart:io';

import 'package:json_api/client.dart';
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
      final r = await client.fetchCollection(Url.collection('companies'));
      expect(r.status, 200);
      expect(r.isSuccessful, true);
      expect(r.document.data.elements.first.attributes['name'], 'Tesla');
      expect(r.document.included, isEmpty);
    });

    test('related collection', () async {
      final r =
          await client.fetchCollection(Url.related('companies', '1', 'models'));
      expect(r.status, 200);
      expect(r.isSuccessful, true);
      expect(r.document.data.elements.first.attributes['name'], 'Roadster');
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
      final r = await client.fetchResource(Url.resource('models', '1'));
      expect(r.status, 200);
      expect(r.isSuccessful, true);
      expect(r.document.data.attributes['name'], 'Roadster');
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
      final r = await client.fetchResource(Url.related('companies', '1', 'hq'));
      expect(r.status, 200);
      expect(r.isSuccessful, true);
      expect(r.document.data.attributes['name'], 'Palo Alto');
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
      final r =
          await client.fetchToOne(Url.relationship('companies', '1', 'hq'));
      expect(r.status, 200);
      expect(r.isSuccessful, true);
      expect(r.document.data.type, 'cities');
    });

    test('empty to-one', () async {
      final r =
          await client.fetchToOne(Url.relationship('companies', '3', 'hq'));
      expect(r.status, 200);
      expect(r.isSuccessful, true);
      expect(r.document.data, isNull);
    });

    test('generic to-one', () async {
      final r = await client
          .fetchRelationship(Url.relationship('companies', '1', 'hq'));
      expect(r.status, 200);
      expect(r.isSuccessful, true);
      expect(r.document.data, TypeMatcher<IdentifierObject>());
      expect((r.document.data as IdentifierObject).type, 'cities');
    });

    test('to-many', () async {
      final r = await client
          .fetchToMany(Url.relationship('companies', '1', 'models'));
      expect(r.status, 200);
      expect(r.isSuccessful, true);
      expect(r.document.data.elements.first.type, 'models');
    });

    test('empty to-many', () async {
      final r = await client
          .fetchToMany(Url.relationship('companies', '3', 'models'));
      expect(r.status, 200);
      expect(r.isSuccessful, true);
      expect(r.document.data.elements, isEmpty);
    });

    test('generic to-many', () async {
      final r = await client
          .fetchRelationship(Url.relationship('companies', '1', 'models'));
      expect(r.status, 200);
      expect(r.isSuccessful, true);
      expect(r.document.data, TypeMatcher<IdentifierCollection>());
      expect((r.document.data as IdentifierCollection).elements.first.type,
          'models');
    });
  });
}
