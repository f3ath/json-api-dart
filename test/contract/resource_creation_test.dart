import 'package:json_api/client.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'shared.dart';

void main() {
  HttpHandler server;
  JsonApiClient client;

  setUp(() async {
    server = initServer();
    client = JsonApiClient(RecommendedUrlDesign.pathOnly, httpHandler: server);
  });

  group('Resource creation', () {
    test('Resource id assigned on the server', () async {
      await client
          .createNew('posts', attributes: {'title': 'Hello world'}).then((r) {
        expect(r.http.statusCode, 201);
        // TODO: Why does "Location" header not work in browsers?
        expect(r.http.headers['location'], '/posts/${r.resource.id}');
        expect(r.links['self'].toString(), '/posts/${r.resource.id}');
        expect(r.resource.type, 'posts');
        expect(r.resource.id, isNotEmpty);
        expect(r.resource.attributes['title'], 'Hello world');
        expect(r.resource.links['self'].toString(), '/posts/${r.resource.id}');
      });
    });
    test('Resource id assigned on the client', () async {
      final id = Uuid().v4();
      await client
          .create('posts', id, attributes: {'title': 'Hello world'}).then((r) {
        expect(r.http.statusCode, 204);
        expect(r.resource, isNull);
        expect(r.http.headers['location'], isNull);
      });
    });
  });
}
