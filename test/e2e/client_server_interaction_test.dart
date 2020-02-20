import 'dart:io';

import 'package:http/http.dart';
import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:json_api/query.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/client/dart_http.dart';
import 'package:pedantic/pedantic.dart';
import 'package:test/test.dart';

void main() {
  group('Client-Server interation over HTTP', () {
    final port = 8088;
    final host = 'localhost';
    final routing =
        StandardRouting(Uri(host: host, port: port, scheme: 'http'));
    final repo = InMemoryRepository({'writers': {}, 'books': {}});
    final jsonApiServer = JsonApiServer(routing, RepositoryController(repo));
    final serverHandler = DartServer(jsonApiServer);
    Client httpClient;
    RoutingClient client;
    HttpServer server;

    setUp(() async {
      server = await HttpServer.bind(host, port);
      httpClient = Client();
      client = RoutingClient(JsonApiClient(DartHttp(httpClient)), routing);
      unawaited(server.forEach(serverHandler));
    });

    tearDown(() async {
      httpClient.close();
      await server.close();
    });

    test('Happy Path', () async {
      final writer =
          Resource('writers', '1', attributes: {'name': 'Martin Fowler'});
      final book = Resource('books', '2', attributes: {'title': 'Refactoring'});

      await client.createResource(writer);
      await client.createResource(book);
      await client
          .updateResource(Resource('books', '2', toMany: {'authors': []}));
      await client.addToRelationship(
          'books', '2', 'authors', [Identifier('writers', '1')]);

      final response = await client.fetchResource('books', '2',
          parameters: Include(['authors']));

      expect(response.data.unwrap().attributes['title'], 'Refactoring');
      expect(response.data.included.first.unwrap().attributes['name'],
          'Martin Fowler');
    });
  }, testOn: 'vm');
}
