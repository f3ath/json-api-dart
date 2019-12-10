import 'dart:io';

import 'package:http/http.dart';
import 'package:json_api/json_api.dart';
import 'package:json_api/server.dart';
import 'package:test/test.dart';

import '../../example/cars_server.dart';

void main() async {
  HttpServer server;
  Client httpClient;
  JsonApiClient client;
  final port = 8082;
  final url = PathBasedUrlDesign(Uri.parse('http://localhost:$port'));

  setUp(() async {
    httpClient = Client();
    client = JsonApiClient(httpClient);
    server = await createServer(InternetAddress.loopbackIPv4, port);
  });

  tearDown(() async {
    httpClient.close();
    await server.close();
  });

  group('resource', () {
    /// A server MUST return a 204 No Content status code if a deletion query
    /// is successful and no content is returned.
    ///
    /// https://jsonapi.org/format/#crud-deleting-responses-204
    test('204 No Content', () async {
      final r0 = await client.deleteResource(url.resource('models', '1'));

      expect(r0.status, 204);
      expect(r0.isSuccessful, true);
      expect(r0.document, isNull);

      // Make sure the resource is not available anymore
      final r1 = await client.fetchResource(url.resource('models', '1'));
      expect(r1.status, 404);
    });

    /// A server MUST return a 200 OK status code if a deletion query
    /// is successful and the server responds with only top-level meta data.
    ///
    /// https://jsonapi.org/format/#crud-deleting-responses-200
    test('200 OK', () async {
      final r0 =
          await client.deleteResource(url.resource('companies', '1'));

      expect(r0.status, 200);
      expect(r0.isSuccessful, true);
      expect(r0.document.meta['dependenciesCount'], 5);

      // Make sure the resource is not available anymore
      final r1 =
          await client.fetchResource(url.resource('companies', '1'));
      expect(r1.status, 404);
    });

    /// https://jsonapi.org/format/#crud-deleting-responses-404
    ///
    /// A server SHOULD return a 404 Not Found status code if a deletion query
    /// fails due to the resource not existing.
    test('404 Not Found', () async {
      final r0 =
          await client.deleteResource(url.resource('models', '555'));
      expect(r0.status, 404);
    });
  }, testOn: 'vm');
}
