@TestOn('vm')
import 'dart:io';

import 'package:json_api/client.dart';
import 'package:json_api/src/server/simple_server.dart';
import 'package:test/test.dart';

import '../../example/cars_server.dart';

void main() async {
  final client = JsonApiClient();
  SimpleServer s;
  setUp(() async {
    s = createServer();
    return await s.start(InternetAddress.loopbackIPv4, 8080);
  });

  tearDown(() => s.stop());

  group('resource', () {
    /// https://jsonapi.org/format/#crud-deleting-responses-204
    ///
    /// A server MUST return a 204 No Content status code if a deletion request
    /// is successful and no content is returned.
    test('204 No Content', () async {
      final r0 = await client.deleteResource(Url.resource('models', '1'));

      expect(r0.status, 204);
      expect(r0.isSuccessful, true);
      expect(r0.document, isNull);

      // Make sure the resource is not available anymore
      final r1 = await client.fetchResource(Url.resource('models', '1'));
      expect(r1.status, 404);
    });

    test('200 OK', () async {
      // Json-Api-Options header is not a part of the standard!
      final r0 = await client.deleteResource(Url.resource('models', '1'),
          headers: {'Json-Api-Options': 'meta'});

      expect(r0.status, 200);
      expect(r0.isSuccessful, true);
      expect(r0.document.meta['Server'],
          'Dart JSON:API Server. https://pub.dartlang.org/packages/json_api');

      // Make sure the resource is not available anymore
      final r1 = await client.fetchResource(Url.resource('models', '1'));
      expect(r1.status, 404);
    });

    /// https://jsonapi.org/format/#crud-deleting-responses-404
    ///
    /// A server SHOULD return a 404 Not Found status code if a deletion request
    /// fails due to the resource not existing.
    test('404 Not Found', () async {
      final r0 = await client.fetchResource(Url.resource('models', '555'));
      expect(r0.status, 404);
    });
  });
}
