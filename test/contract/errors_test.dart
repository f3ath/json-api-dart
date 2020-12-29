import 'package:json_api/client.dart';
import 'package:json_api/http.dart';
import 'package:test/test.dart';

import '../../demo/demo_handler.dart';

void main() {
  late BasicClient client;

  setUp(() async {
    client = BasicClient(DemoHandler());
  });

  group('Errors', () {
    test('Method not allowed', () async {
      final actions = [
        () => client.send(Uri.parse('/posts'), Request('delete')),
        () => client.send(Uri.parse('/posts/1'), Request('post')),
        () => client.send(Uri.parse('/posts/1/author'), Request('post')),
        () => client.send(
            Uri.parse('/posts/1/relationships/author'), Request('head')),
      ];
      for (final action in actions) {
        try {
          await action();
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
  });
}
