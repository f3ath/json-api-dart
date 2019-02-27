@TestOn('browser')
import 'package:http/browser_client.dart';
import 'package:json_api/client.dart';
import 'package:test/test.dart';

void main() async {
  test('can fetch collection', () async {
    final channel = spawnHybridUri('test_server.dart');
    final client = JsonApiClient(factory: () => BrowserClient());
    final port = await channel.stream.first;
    final r =
        await client.fetchCollection(Uri.parse('http://localhost:$port/brands'));
    expect(r.status, 200);
    expect(r.isSuccessful, true);
    expect(r.document.collection.first.attributes['name'], 'Tesla');
    expect(r.document.included, isEmpty);
  }, tags: ['browser-only']);
}
