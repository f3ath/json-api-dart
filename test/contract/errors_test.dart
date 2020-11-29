import 'package:json_api/client.dart';
import 'package:json_api/core.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:test/test.dart';

import '../src/demo_handler.dart';

void main() {
  late JsonApiClient client;

  setUp(() async {
    client = JsonApiClient(DemoHandler(), RecommendedUrlDesign.pathOnly);
  });

  group('Errors', () {
    test('Method not allowed', () async {
      final ref = Ref('posts', '1');
      final badRequests = [
        Request('delete', CollectionTarget('posts')),
        Request('post', ResourceTarget(ref)),
        Request('post', RelatedTarget(ref, 'author')),
        Request('head', RelationshipTarget(ref, 'author')),
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
      final r = await DemoHandler()
          .call(HttpRequest('get', Uri.parse('/a/long/prefix/')));
      expect(r.statusCode, 400);
    });
    test('404', () async {
      final actions = <Future Function()>[
        () => client.fetchCollection('unicorns'),
        () => client.fetchResource('posts', '1'),
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
