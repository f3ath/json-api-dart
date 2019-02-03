import 'dart:convert';
import 'dart:io';

import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:test/test.dart';

import 'test_server.dart';

void main() {
  final client = JsonApiClient();
  TestServer s;
  setUp(() async {
    s = TestServer();
    await s.start(InternetAddress.loopbackIPv4, 8080);
  });

  tearDown(() async {
    await s.stop();
  });

  test('traversing a collection', () async {
    final page =
        await client.fetchCollection(Uri.parse('http://localhost:8080/brands'));

    final tesla = page.resources.first;
    expect(tesla.attributes['name'], 'Tesla');

    final city = await tesla.toOne('headquarters').fetchRelated(client);

    expect(city.resource.attributes['name'], 'Palo Alto');
  });

  test('fetching relationships', () async {

    final hq = await client.fetchRelationship(
        Uri.parse('http://localhost:8080/brands/1/relationships/headquarters'));

    final city = await (hq as ToOne).fetchRelated(client);
    expect(city.resource.attributes['name'], 'Palo Alto');

    final models = await client.fetchRelationship(
        Uri.parse('http://localhost:8080/brands/1/relationships/models'));

    final cars = await (models as ToMany).fetchRelated(client);
    expect(cars.resources.length, 4);
    expect(cars.resources.map((_) => _.attributes['name']), contains('Model 3'));
  });

  test('fetching pages', () async {
    final page1 =
        await client.fetchCollection(Uri.parse('http://localhost:8080/brands'));
    final page2 = await page1.fetchNext(client);
    final first = await page2.fetchFirst(client);
    expect(json.encode(page1), json.encode(first));
    expect(json.encode(await page2.fetchPrev(client)), json.encode(first));
    expect(json.encode(await page2.fetchLast(client)),
        json.encode(await page1.fetchLast(client)));
  });

  test('get collection - 404', () async {
    final c = JsonApiClient();
    try {
      await c.fetchCollection(Uri.parse('http://localhost:8080/unicorns'));
      fail('exception expected');
    } on NotFoundException {}
  });
}
