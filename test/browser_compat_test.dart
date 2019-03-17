@TestOn('browser')
import 'package:http/browser_client.dart';
import 'package:json_api/client.dart';
import 'package:test/test.dart';

void main() async {
  test('can fetch collection', () async {
    final channel = spawnHybridUri('test_server.dart');
    final client = JsonApiClient(factory: () => BrowserClient());
    final port = await channel.stream.first;
    print('Port: $port');
    final r = await client
        .fetchCollection(Uri.parse('http://localhost:$port/companies'));
    expect(r.status, 200);
    expect(r.isSuccessful, true);
    expect(r.data.resourceObjects.first.attributes['name'], 'Tesla');
  });
}
