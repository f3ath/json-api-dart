import 'dart:io';

import 'package:json_api/client.dart';
import 'package:json_api/src/server/simple_server.dart';
import 'package:json_api/src/transport/relationship.dart';
import 'package:test/test.dart';

import '../../example/cars_server.dart';

void main() {
  group('Fetch', () {
    final client = JsonApiClient();
    SimpleServer s;
    setUp(() async {
      s = createServer();
      await s.start(InternetAddress.loopbackIPv4, 8080);
    });

    tearDown(() async {
      await s.stop();
    });

    final baseUri = Uri.parse('http://localhost:8080');

    collection(String type) => baseUri.replace(path: '/$type');

    resource(String type, String id) => baseUri.replace(path: '/$type/$id');

    related(String type, String id, String rel) =>
        baseUri.replace(path: '/$type/$id/$rel');

    relationship(String type, String id, String rel) =>
        baseUri.replace(path: '/$type/$id/relationships/$rel');

    group('collection', () {
      test('resource collection', () async {
        final r = await client.fetchCollection(collection('brands'));
        expect(r.status, 200);
        expect(r.isSuccessful, true);
        expect(r.document.collection.first.attributes['name'], 'Tesla');
        expect(r.document.included, isEmpty);
      });

      test('related collection', () async {
        final r =
            await client.fetchCollection(related('brands', '1', 'models'));
        expect(r.status, 200);
        expect(r.isSuccessful, true);
        expect(r.document.collection.first.attributes['name'], 'Roadster');
      });

      test('404', () async {
        final r = await client.fetchCollection(collection('unicorns'));
        expect(r.status, 404);
        expect(r.isSuccessful, false);
        expect(r.errorDocument.errors.first.detail, 'Unknown resource type');
      });
    });

    group('single resource', () {
      test('single resource', () async {
        final r = await client.fetchResource(resource('cars', '1'));
        expect(r.status, 200);
        expect(r.isSuccessful, true);
        expect(r.document.resourceObject.attributes['name'], 'Roadster');
      });

      test('related resource', () async {
        final r = await client.fetchResource(related('brands', '1', 'hq'));
        expect(r.status, 200);
        expect(r.isSuccessful, true);
        expect(r.document.resourceObject.attributes['name'], 'Palo Alto');
      });

      test('404', () async {
        final r = await client.fetchResource(resource('unicorns', '1'));
        expect(r.status, 404);
        expect(r.isSuccessful, false);
      });
    });

    group('relationships', () {
      test('to-one', () async {
        final r = await client.fetchToOne(relationship('brands', '1', 'hq'));
        expect(r.status, 200);
        expect(r.isSuccessful, true);
        expect(r.document.toIdentifier().type, 'cities');
      });

      test('generic to-one', () async {
        final r =
            await client.fetchRelationship(relationship('brands', '1', 'hq'));
        expect(r.status, 200);
        expect(r.isSuccessful, true);
        expect(r.document, TypeMatcher<ToOne>());
        expect((r.document as ToOne).toIdentifier().type, 'cities');
      });

      test('to-many', () async {
        final r =
            await client.fetchToMany(relationship('brands', '1', 'models'));
        expect(r.status, 200);
        expect(r.isSuccessful, true);
        expect(r.document.toIdentifiers().first.type, 'cars');
      });

      test('generic to-many', () async {
        final r = await client
            .fetchRelationship(relationship('brands', '1', 'models'));
        expect(r.status, 200);
        expect(r.isSuccessful, true);
        expect(r.document, TypeMatcher<ToMany>());
        expect((r.document as ToMany).toIdentifiers().first.type, 'cars');
      });
    });
  }, tags: ['vm-only']);
}
