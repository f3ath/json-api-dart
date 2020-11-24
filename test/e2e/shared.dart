import 'package:json_api/client.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

void expectAllHttpMethodsToWork(JsonApiClient client) async {
  final id = Uuid().v4();
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
    expect(r.collection, isEmpty);
  });
}
