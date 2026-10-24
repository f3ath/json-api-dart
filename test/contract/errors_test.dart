import 'package:http_interop/http_interop.dart' as http;
import 'package:json_api/client.dart';
import 'package:json_api/server.dart';
import 'package:test/test.dart';

import '../test_handler.dart';

void main() {
  late Client client;

  setUp(() async {
    client = Client(
      testHandler(
        onPayload: (request, controller) async {
          if (request is CreateResourceRequest && request.newResource.id != null) {
            throw ClientGeneratedIdNotSupported();
          }
          return null;
        },
      ),
    );
  });

  group('Errors', () {
    test('Forbidden when client-generated id is not supported', () async {
      final r = await client.send(
        Uri.parse('/posts'),
        Request.post({
          'data': {'type': 'posts', 'id': 'client-generated-id'},
        }),
      );
      expect(r.httpResponse.statusCode, 403);
    });
    test('Bad request when payload is missing', () async {
      final r = await testHandler()(
        http.Request('post', Uri.parse('/posts'), http.Body.empty(), http.Headers()),
      );
      expect(r.statusCode, 400);
    });
    for (final payload in ['{', '[]', 'null', '42', '"text"']) {
      test('Bad request when payload is invalid: $payload', () async {
        final r = await testHandler()(
          http.Request('post', Uri.parse('/posts'), http.Body.text(payload), http.Headers()),
        );
        expect(r.statusCode, 400);
      });
    }
    test('Method not allowed', () async {
      final actions = [
        () => client.send(Uri.parse('/posts'), Request('delete')),
        () => client.send(Uri.parse('/posts/1'), Request('post')),
        () => client.send(Uri.parse('/posts/1/author'), Request('post')),
        () => client.send(Uri.parse('/posts/1/relationships/author'), Request('head')),
      ];
      for (final action in actions) {
        final response = await action();
        expect(response.httpResponse.statusCode, 405);
      }
    });
    test('Bad request when target can not be matched', () async {
      final r = await testHandler()(
        http.Request('get', Uri.parse('/a/long/prefix/'), http.Body.empty(), http.Headers()),
      );
      expect(r.statusCode, 400);
    });
    test('Unsupported extension', () async {
      final r = await testHandler()(
        http.Request(
          'get',
          Uri.parse('/posts/1'),
          http.Body.empty(),
          http.Headers.from({
            'Content-Type': ['application/vnd.api+json; ext=foobar'],
            'Accept': ['application/vnd.api+json'],
          }),
        ),
      );
      expect(r.statusCode, 415);
    });
    test('Unacceptable', () async {
      final r = await testHandler()(
        http.Request(
          'get',
          Uri.parse('/posts/1'),
          http.Body.empty(),
          http.Headers.from({
            'Content-Type': ['application/vnd.api+json'],
            'Accept': ['application/vnd.api+json; ext=foobar'],
          }),
        ),
      );
      expect(r.statusCode, 406);
    });
  });
}
