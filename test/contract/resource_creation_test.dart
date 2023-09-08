import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:json_api/routing.dart';
import 'package:test/test.dart';

import '../test_handler.dart';

void main() {
  late RoutingClient client;

  setUp(() async {
    client = RoutingClient(StandardUriDesign.pathOnly, Client(TestHandler()));
  });

  group('Resource creation', () {
    test('Resource id assigned on the server', () async {
      await client
          .createNew('posts', attributes: {'title': 'Hello world'}).then((r) {
        expect(r.httpResponse.statusCode, 201);
        expect(r.httpResponse.headers['location'], ['/posts/${r.resource.id}']);
        expect(r.links['self'].toString(), '/posts/${r.resource.id}');
        expect(r.resource.type, 'posts');
        expect(r.resource.attributes['title'], 'Hello world');
        expect(r.resource.links['self'].toString(), '/posts/${r.resource.id}');
      });
    });

    test('Resource id assigned on the server using local id', () async {
      await client.createNew('posts',
          lid: 'lid',
          attributes: {'title': 'Hello world'},
          one: {'self': LocalIdentifier('posts', 'lid')}).then((r) {
        expect(r.httpResponse.statusCode, 201);
        expect(r.httpResponse.headers['location'], ['/posts/${r.resource.id}']);
        expect(r.links['self'].toString(), '/posts/${r.resource.id}');
        expect(r.resource.type, 'posts');
        expect(r.resource.attributes['title'], 'Hello world');
        expect(r.resource.links['self'].toString(), '/posts/${r.resource.id}');
      });
    });

    test('Resource id assigned on the client', () async {
      await client.create('posts', '12345',
          attributes: {'title': 'Hello world'}).then((r) {
        expect(r.httpResponse.statusCode, 204);
        expect(r.resource, isNull);
        expect(r.httpResponse.headers['location'], isNull);
      });
    });
  });
}
