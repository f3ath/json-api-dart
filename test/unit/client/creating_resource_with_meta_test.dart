import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';
import 'package:test/test.dart';

import '../../helper/expect_resources_equal.dart';

void main() async {
  final host = 'localhost';
  final port = 80;
  final base = Uri(scheme: 'http', host: host, port: port);
  final routing = StandardRouting(base);

  group('Client-generated ID', () {
    JsonApiClient client;
    RoutingClient routingClient;

    setUp(() async {
      final repository = InMemoryRepository({
        'books': {},
        'people': {},
        'companies': {},
        'noServerId': {},
        'fruits': {},
        'apples': {}
      });
      final server = JsonApiServer(RepositoryController(repository));
      client = JsonApiClient(server);
      routingClient = RoutingClient(client, routing);
    });

    test('204 No Content', () async {
      final person =
          Resource('people', '123', attributes: {'name': 'Martin Fowler'});
      final r = await client.createResourceAt(
          routing.collection('people'), person,
          meta: {'456': 'friends'});
      expect(r.isSuccessful, isTrue);
      expect(r.statusCode, 204);
      expect(r.location, isNull);
      expect(r.data, isNull);
      final r1 = await routingClient.fetchResource(person.type, person.id);
      expect(r1.isSuccessful, isTrue);
      expect(r1.statusCode, 200);
      expectResourcesEqual(r1.data.unwrap(), person);
    });
  });
}
