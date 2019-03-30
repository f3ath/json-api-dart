import 'dart:io';

import 'package:json_api/jaon_api.dart';
import 'package:test/test.dart';

import '../../example/cars_server.dart';

void main() async {
  HttpServer server;
  final client = JsonApiClient();
  setUp(() async {
    server = await createServer(InternetAddress.loopbackIPv4, 8080);
  });

  tearDown(() async => await server.close());

  group('resource', () {
    /// A server MUST return a 204 No Content status code if a deletion request
    /// is successful and no content is returned.
    ///
    /// https://jsonapi.org/format/#crud-deleting-responses-204
    test('204 No Content', () async {
      final r0 = await client.deleteResource(Url.resource('models', '1'));

      expect(r0.status, 204);
      expect(r0.isSuccessful, true);
      expect(r0.document, isNull);

      // Make sure the resource is not available anymore
      final r1 = await client.fetchResource(Url.resource('models', '1'));
      expect(r1.status, 404);
    });

    /// A server MUST return a 200 OK status code if a deletion request
    /// is successful and the server responds with only top-level meta data.
    ///
    /// https://jsonapi.org/format/#crud-deleting-responses-200
    test('200 OK', () async {
      final r0 = await client.deleteResource(Url.resource('companies', '1'));

      expect(r0.status, 200);
      expect(r0.isSuccessful, true);
      expect(r0.document.meta['dependenciesCount'], 5);

      // Make sure the resource is not available anymore
      final r1 = await client.fetchResource(Url.resource('companies', '1'));
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
  }, testOn: 'vm');
}
