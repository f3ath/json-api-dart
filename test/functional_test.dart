import 'dart:io';

import 'package:json_api/client.dart';
import 'package:json_api/resource.dart';
import 'package:json_api/simple_server.dart';
import 'package:json_api/src/transport/relationship.dart';
import 'package:test/test.dart';

import '../example/server/server.dart';

void main() {
  group('client-server e2e tests', () {
    final client = Client();
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

      final tesla = page.document.collection.first;
      expect(tesla.attributes['name'], 'Tesla');

      final hqRel = tesla.relationships['headquarters'];
      final city = await (hqRel as ToOne).fetchRelated(client);
      expect(city.attributes['name'], 'Palo Alto');

      final modelsRel = tesla.relationships['models'];
      final models = await (modelsRel as ToMany).fetchRelated(client);
      expect(models.first.attributes['name'], 'Roadster');
    });

    test('fetching pages', () async {
      final page1 = (await client
              .fetchCollection(Uri.parse('http://localhost:8080/brands')))
          .document;
      final page2 = await page1.fetchNext(client);
      final lastPage = await page2.fetchLast(client);

      expect(page2.collection.first.attributes['name'], 'BMW');
      expect(lastPage.collection.first.attributes['name'], 'Toyota');
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
