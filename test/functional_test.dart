import 'dart:convert';
import 'dart:io';

import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:json_api/simple_server.dart';
import 'package:test/test.dart';

import '../example/server/server.dart';

void main() {
  group('client-server e2e tests', () {
    final client = DartHttpClient();
    SimpleServer s;
    setUp(() async {
      s = createServer();
      await s.start(InternetAddress.loopbackIPv4, 8080);
    });

    tearDown(() async {
      await s.stop();
    });

    test('traversing a collection', () async {
      final page = await client
          .fetchCollection(Uri.parse('http://localhost:8080/brands'));

      final tesla = page.document.resources.first;
      expect(tesla.attributes['name'], 'Tesla');

      final city = await tesla.toOne('headquarters').fetchRelated(client);

      expect(city.document.resource.attributes['name'], 'Palo Alto');
    });

    test('fetching relationships', () async {
      final hq = await client.fetchToOne(Uri.parse(
          'http://localhost:8080/brands/1/relationships/headquarters'));

      final city = await hq.document.fetchRelated(client);
      expect(city.document.resource.attributes['name'], 'Palo Alto');

      final models = await client.fetchToMany(
          Uri.parse('http://localhost:8080/brands/1/relationships/models'));

      final cars = await models.document.fetchRelated(client);
      expect(cars.document.resources.length, 4);
      expect(cars.document.resources.map((_) => _.attributes['name']),
          contains('Model 3'));
    });

    test('fetching pages', () async {
      final page1 = (await client
              .fetchCollection(Uri.parse('http://localhost:8080/brands')))
          .document;
      final page2 = await page1.fetchNext(client);
      final first = await page2.fetchFirst(client);
      expect(json.encode(page1), json.encode(first));
      expect(json.encode(await page2.fetchPrev(client)), json.encode(first));
      expect(json.encode(await page2.fetchLast(client)),
          json.encode(await page1.fetchLast(client)));
    });

    test('creating resources', () async {
      final modelY = Resource('cars', '100', attributes: {'name': 'Model Y'});
      final result = await client.createResource(
          Uri.parse('http://localhost:8080/cars'), modelY);

      expect(result.isSuccessful, true);

      final models = await client.addToMany(
          Uri.parse('http://localhost:8080/brands/1/relationships/models'),
          [Identifier('cars', '100')]);

      expect(models.document.identifiers.map((_) => _.id), contains('100'));
    });

    test('get collection - 404', () async {
      final res = await client
          .fetchCollection(Uri.parse('http://localhost:8080/unicorns'));

      expect(res.status, 404);
    });
  }, tags: ['vm-only']);
}
