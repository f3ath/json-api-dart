import 'package:json_api/client.dart';
import 'package:json_api/routing.dart';
import 'package:test/test.dart';

import '../src/demo_handler.dart';

void main() {
  late JsonApiClient client;

  setUp(() async {
    client = JsonApiClient(DemoHandler(), RecommendedUrlDesign.pathOnly);
  });

  group('Resource creation', () {
    test('Resource id assigned on the server', () async {
      await client
          .createNew('posts', attributes: {'title': 'Hello world'}).then((r) {
        expect(r.http.statusCode, 201);
        // TODO: Why does "Location" header not work in browsers?
        expect(r.http.headers['location'], '/posts/${r.resource.ref.id}');
        expect(r.links['self'].toString(), '/posts/${r.resource.ref.id}');
        expect(r.resource.ref.type, 'posts');
        expect(r.resource.attributes['title'], 'Hello world');
        expect(
            r.resource.links['self'].toString(), '/posts/${r.resource.ref.id}');
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
