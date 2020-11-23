import 'package:json_api/client.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:test/test.dart';

import 'shared.dart';

void main() {
  HttpHandler server;
  JsonApiClient client;

  setUp(() async {
    server = initServer();
    client = JsonApiClient(RecommendedUrlDesign.pathOnly, httpHandler: server);
  });

  group('Errors', () {
    test('Method not allowed', () async {
      final badRequests = [
        Request('delete', CollectionTarget('posts')),
        Request('post', ResourceTarget('posts', '1')),
        Request('post', RelatedTarget('posts', '1', 'author')),
        Request('head', RelationshipTarget('posts', '1', 'author')),
      ];
      for (final request in badRequests) {
        try {
          await client.send(request);
          fail('Exception expected');
        } on RequestFailure catch (response) {
          expect(response.http.statusCode, 405);
        }
      }
    });
    test('Bad request when target can not be matched', () async {
      try {
        await JsonApiClient(RecommendedUrlDesign(Uri.parse('/a/long/prefix/')),
                httpHandler: server)
            .fetchCollection('posts');
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 400);
      }
    });
    test('404', () async {
      final actions = <Future Function()>[
        () => client.fetchCollection('unicorns')
      ];
      for (final action in actions) {
        try {
          await action();
          fail('Exception expected');
        } on RequestFailure catch (e) {
          expect(e.http.statusCode, 404);
        }
      }
    });
  });
}
