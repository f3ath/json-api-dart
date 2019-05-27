@TestOn('browser')
import 'package:json_api/json_api.dart';
import 'package:test/test.dart';

void main() async {
  test('can fetch collection', () async {
    final channel = spawnHybridUri('test_server.dart');
    final client = JsonApiClient();
    final port = await channel.stream.first;
    final r = await client
        .fetchCollection(Uri.parse('http://localhost:$port/companies'));
    expect(r.status, 200);
    expect(r.isSuccessful, true);
    expect(r.data.collection.first.attributes['name'], 'Tesla');
  }, testOn: 'browser');
}
