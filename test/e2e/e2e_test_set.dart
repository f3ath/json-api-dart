import 'package:json_api/client.dart';
import 'package:test/test.dart';

void e2eTests(RoutingClient client) async {
  await _testAllHttpMethods(client);
  await _testLocationIsSet(client);
}

Future<void> _testAllHttpMethods(RoutingClient client) async {
  final id = '12345';
  // POST
  await client.create('posts', id, attributes: {'title': 'Hello world'});
  // GET
  await client.fetchResource('posts', id).then((r) {
    expect(r.resource.attributes['title'], 'Hello world');
  });
  // PATCH
  await client.updateResource('posts', id, attributes: {'title': 'Bye world'});
  await client.fetchResource('posts', id).then((r) {
    expect(r.resource.attributes['title'], 'Bye world');
  });
  // DELETE
  await client.deleteResource('posts', id);
  await client.fetchCollection('posts').then((r) {
    expect(r.collection.length, isEmpty);
  });
}

Future<void> _testLocationIsSet(RoutingClient client) async {
  await client
      .createNew('posts', attributes: {'title': 'Location test'}).then((r) {
    expect(r.http.headers['Location'], isNotEmpty);
  });
}
