import 'dart:io';

import 'package:http/http.dart';
import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:json_api/query.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/client/dart_http.dart';
import 'package:json_api/uri_design.dart';
import 'package:pedantic/pedantic.dart';
import 'package:test/test.dart';

void main() {
  group('Client-Server interation over HTTP', () {
    final port = 8088;
    final host = 'localhost';
    final design =
        UriDesign.standard(Uri(host: host, port: port, scheme: 'http'));
    final repo = InMemoryRepository({'writers': {}, 'books': {}});
    final jsonApiServer = JsonApiServer(design, RepositoryController(repo));
    final serverHandler = DartServerHandler(jsonApiServer);
    Client httpClient;
    JsonApiClient client;
    HttpServer server;

    setUp(() async {
      server = await HttpServer.bind(host, port);
      httpClient = Client();
      client = JsonApiClient(DartHttp(httpClient), uriFactory: design);
      unawaited(server.forEach(serverHandler));
    });

    tearDown(() async {
      httpClient.close();
      await server.close();
    });

    test('can create and fetch resources', () async {
      await client.createResource(
          Resource('writers', '1', attributes: {'name': 'Martin Fowler'}));

      await client.createResource(Resource('books', '2', attributes: {
        'title': 'Refactoring'
      }, toMany: {
        'authors': [Identifier('writers', '1')]
      }));

      final response = await client.fetchResource('books', '2',
          parameters: Include(['authors']));

      expect(response.data.unwrap().attributes['title'], 'Refactoring');
      expect(response.data.included.first.unwrap().attributes['name'],
          'Martin Fowler');
    });
  }, testOn: 'vm');
}
