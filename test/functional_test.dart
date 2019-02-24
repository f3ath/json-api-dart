import 'dart:io';

import 'package:json_api/client.dart';
import 'package:json_api/resource.dart';
import 'package:json_api/simple_server.dart';
import 'package:json_api/src/transport/relationship.dart';
import 'package:test/test.dart';

import '../example/server/server.dart';
import 'cars_client.dart';

void main() {
  group('client-server e2e tests', () {
    final client = Client();
    final cars = CarsClient(client);
    SimpleServer s;
    setUp(() async {
      s = createServer();
      await s.start(InternetAddress.loopbackIPv4, 8080);
    });

    tearDown(() async {
      await s.stop();
    });

    group('Fetch', () {
      test('resources', () async {
        final brands = await cars.fetchCollection('brands');

        final tesla = brands.collection.first;
        expect(tesla.attributes['name'], 'Tesla');

        final hqRel = tesla.relationships['headquarters'];
        final city = await (hqRel as ToOne).fetchRelated(client);
        expect(city.attributes['name'], 'Palo Alto');

        final modelsRel = tesla.relationships['models'];
        final models = await (modelsRel as ToMany).fetchRelated(client);
        expect(models.first.attributes['name'], 'Roadster');
      });

      test('relationships', () async {
        final hq = await cars.fetchToOne('brands', '1', 'headquarters');
        expect(hq.identifier.type, 'cities');
      });

      test('collection pages', () async {
        final page1 = await cars.fetchCollection('brands');
        final page2 = await page1.fetchNext(client);
        final lastPage = await page2.fetchLast(client);

        expect(page2.collection.first.attributes['name'], 'BMW');
        expect(lastPage.collection.first.attributes['name'], 'Toyota');
      });

      test('collection 404', () async {
        final res = await client
            .fetchCollection(Uri.parse('http://localhost:8080/unicorns'));

        expect(res.status, 404);
      });
    });

    group('Create', () {
      test('resource', () async {
        final modelY = Resource('cars', '100', attributes: {'name': 'Model Y'});
        final result = await client.createResource(
            Uri.parse('http://localhost:8080/cars'), modelY);

        expect(result.isSuccessful, true);

        final models = await client.addToMany(
            Uri.parse('http://localhost:8080/brands/1/relationships/models'),
            [Identifier('cars', '100')]);

        expect(models.document.identifiers.map((_) => _.id), contains('100'));
      });
    });

    group('Update', () {
      test('can update a resource', () async {
        final brand = (await cars.fetchResource('brands', '2')).toResource();

        expect(brand.attributes['name'], 'BMW');
        brand.attributes['name'] = 'Daimler AG';

        await client.updateResource(
            Uri.parse('http://localhost:8080/brands/2'), brand);

        final brandUpdated =
            (await cars.fetchResource('brands', '2')).toResource();

        expect(brandUpdated.attributes['name'], 'Daimler AG');
      });
    });
  }, tags: ['vm-only']);
}
