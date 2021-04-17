import 'package:json_api/client.dart';
import 'package:json_api/routing.dart';
import '../../example/server/demo_handler.dart';
import 'package:test/test.dart';

void main() {
  late RoutingClient client;

  setUp(() async {
    client = RoutingClient(StandardUriDesign.pathOnly,
        client: Client(handler: DemoHandler()));
  });

  group('Resource creation', () {
    test('Resource id assigned on the server', () async {
      await client
          .createNew('posts', attributes: {'title': 'Hello world'}).then((r) {
        expect(r.http.statusCode, 201);
        expect(r.http.headers['location'], '/posts/${r.resource.id}');
        expect(r.links['self'].toString(), '/posts/${r.resource.id}');
        expect(r.resource.type, 'posts');
        expect(r.resource.attributes['title'], 'Hello world');
        expect(r.resource.links['self'].toString(), '/posts/${r.resource.id}');
      });
    });
    test('Resource id assigned on the client', () async {
      await client.create('posts', '12345',
          attributes: {'title': 'Hello world'}).then((r) {
        expect(r.http.statusCode, 204);
        expect(r.resource, isNull);
        expect(r.http.headers['location'], isNull);
      });
    });
  });
}
