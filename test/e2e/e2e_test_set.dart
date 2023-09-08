import 'package:json_api/client.dart';
import 'package:test/test.dart';

Future<void> testAllHttpMethods(RoutingClient Function() client) async {
  final id = '12345';
  test('POST', () async {
    await client().create('posts', id, attributes: {'title': 'Hello world'});
  });
  test('GET', () async {
    await client().fetchResource('posts', id).then((r) {
      expect(r.resource.attributes['title'], 'Hello world');
    });
  });
  test('PATCH', () async {
    await client()
        .updateResource('posts', id, attributes: {'title': 'Bye world'});
    await client().fetchResource('posts', id).then((r) {
      expect(r.resource.attributes['title'], 'Bye world');
    });
  });
  test('DELETE', () async {
    await client().deleteResource('posts', id);
    await client().fetchCollection('posts').then((r) {
      expect(r.collection, isEmpty);
    });
  });
}

void testLocationIsSet(RoutingClient Function() client) {
  test('Location is set', () async {
    final r = await client()
        .createNew('posts', attributes: {'title': 'Location test'});
    expect(r.httpResponse.headers['Location'], isNotEmpty);
    await client().deleteResource('posts', r.resource.id);
  });
}
