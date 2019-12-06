import 'package:http/http.dart' as http;
import 'package:json_api/json_api.dart';
import 'package:test/test.dart';

void main() async {
  http.Request request;
  http.Response response;
  final httpClient = http.Client();
  final client = JsonApiClient(httpClient, onHttpCall: (req, resp) {
    request = req;
    response = resp;
  });

  test('can fetch collection', () async {
    final channel = spawnHybridUri('test_server.dart');
    final port = await channel.stream.first;
    final r = await client
        .fetchCollection(Uri.parse('http://localhost:$port/companies'));

    httpClient.close();
    expect(r.status, 200);
    expect(r.isSuccessful, true);
    expect(r.data.unwrap().first.attributes['name'], 'Tesla');

    expect(request, isNotNull);
    expect(response, isNotNull);
    expect(response.body, isNotEmpty);
  }, testOn: 'browser');
}
