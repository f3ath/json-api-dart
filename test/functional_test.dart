import 'dart:io';

import 'package:json_api/client.dart';
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
    final page1 =
        await client.fetchCollection(Uri.parse('http://localhost:8080/brands'));
    expect(page1.resources.first.attributes['name'], 'Tesla');

    final page2 = await client.fetchCollection(page1.next.uri);
    final bmw = await client.fetchResource(page2.resources.first.self.uri);
    expect(bmw.resource.attributes['name'], 'BMW');

    final bmwHeadquarters = await client
        .fetchResource(bmw.resource.relationships['headquarters'].self.uri);

    print(bmwHeadquarters.resource.attributes);
  });

  test('get collection - 404', () async {
    final c = JsonApiClient();
    try {
      await c.fetchCollection(Uri.parse('http://localhost:8080/unicorns'));
      fail('exception expected');
    } on NotFoundException {}
  });
}
