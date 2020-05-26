import 'package:http/http.dart';
import 'package:json_api/json_api.dart';
import 'package:json_api_common/routing.dart';
import 'package:test/test.dart';

void main() async {
  final port = 8081;
  final host = 'localhost';
  final routing = Routing(Uri(host: host, port: port, scheme: 'http'));
  Client httpClient;

  setUp(() {
    httpClient = Client();
  });

  tearDown(() {
    httpClient.close();
  });

  test('can create and fetch', () async {
    final channel = spawnHybridUri('hybrid_server.dart', message: port);
    await channel.stream.first;

    final client = JsonApiClient(DartHttp(httpClient), routing);

    await client
        .createResource('writers', '1', attributes: {'name': 'Martin Fowler'});
    await client
        .createResource('books', '2', attributes: {'title': 'Refactoring'});
    await client.updateResource('books', '2', many: {'authors': []});
    await client.addMany('books', '2', 'authors', [Identifier('writers', '1')]);

    final response =
        await client.fetchResource('books', '2', include: ['authors']);

    expect(response.resource.attributes['title'], 'Refactoring');
    expect(response.included.first.attributes['name'], 'Martin Fowler');
  }, testOn: 'browser');
}
