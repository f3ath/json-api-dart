import 'dart:io';

import 'package:http/http.dart';
import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:json_api/server.dart';
import 'package:json_api/url_design.dart';
import 'package:shelf/shelf_io.dart';
import 'package:test/test.dart';

import '../../example/server.dart';

void main() async {
  HttpServer server;
  Client httpClient;
  JsonApiClient client;
  final host = 'localhost';
  final port = 8081;
  final urlDesign =
      PathBasedUrlDesign(Uri(scheme: 'http', host: host, port: port));

  setUp(() async {
    httpClient = Client();
    client = JsonApiClient(httpClient);
    final handler = createHttpHandler(
        ShelfRequestResponseConverter(), CRUDController(), urlDesign);

    server = await serve(handler, host, port);
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
      final apple = Resource('apples', '1');
      final r0 =
          await client.createResource(urlDesign.collection('apples'), apple);

      expect(r0.isSuccessful, true);

      final r1 = await client.deleteResource(urlDesign.resource('apples', '1'));

      expect(r1.status, 204);
      expect(r1.isSuccessful, true);
      expect(r1.document, isNull);

      // Make sure the resource is not available anymore
      final r2 = await client.fetchResource(urlDesign.resource('apples', '1'));
      expect(r2.status, 404);
    });

    /// A server MUST return a 200 OK status code if a deletion query
    /// is successful and the server responds with only top-level meta data.
    ///
    /// https://jsonapi.org/format/#crud-deleting-responses-200
    test('200 OK', () async {
      final apple = Resource('apples', '1',
          toOne: {'origin': Identifier('countries', '2')});
      final r0 =
          await client.createResource(urlDesign.collection('apples'), apple);

      expect(r0.isSuccessful, true);

      final r1 = await client.deleteResource(urlDesign.resource('apples', '1'));

      expect(r1.status, 200);
      expect(r1.isSuccessful, true);
      expect(r1.document.meta['relationships'], 1);

      // Make sure the resource is not available anymore
      final r2 = await client.fetchResource(urlDesign.resource('apples', '1'));
      expect(r2.status, 404);
    });

    /// https://jsonapi.org/format/#crud-deleting-responses-404
    ///
    /// A server SHOULD return a 404 Not Found status code if a deletion query
    /// fails due to the resource not existing.
    test('404 Not Found', () async {
      final r0 =
          await client.deleteResource(urlDesign.resource('models', '555'));
      expect(r0.status, 404);
    });
  }, testOn: 'vm');
}
