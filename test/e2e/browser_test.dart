import 'package:http/http.dart';
import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:json_api/query.dart';
import 'package:json_api/routing.dart';
import 'package:test/test.dart';

void main() async {
  final port = 8081;
  final host = 'localhost';
  final routing = StandardRouting(Uri(host: host, port: port, scheme: 'http'));
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

    final client = RoutingClient(JsonApiClient(DartHttp(httpClient)), routing);

    final writer =
        Resource('writers', '1', attributes: {'name': 'Martin Fowler'});
    final book = Resource('books', '2', attributes: {'title': 'Refactoring'});

    await client.createResource(writer);
    await client.createResource(book);
    await client
        .updateResource(Resource('books', '2', toMany: {'authors': []}));
    await client.addToRelationship(
        'books', '2', 'authors', [Identifier('writers', '1')]);

    final response = await client.fetchResource('books', '2',
        parameters: Include(['authors']));

    expect(response.data.unwrap().attributes['title'], 'Refactoring');
    expect(response.document.included.first.unwrap().attributes['name'],
        'Martin Fowler');
  }, testOn: 'browser');
}
