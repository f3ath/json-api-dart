import 'dart:io';

import 'package:http/http.dart';
import 'package:json_api/json_api.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/dart_http.dart';
import 'package:json_api_common/routing.dart';
import 'package:pedantic/pedantic.dart';
import 'package:test/test.dart';

void main() {
  group('Client-Server interaction over HTTP', () {
    final port = 8088;
    final host = 'localhost';
    final routing = Routing(Uri(host: host, port: port, scheme: 'http'));
    final repo = InMemoryRepository({'writers': {}, 'books': {}});
    final jsonApiServer = JsonApiServer(RepositoryController(repo));
    final serverHandler = DartServer(jsonApiServer);
    Client httpClient;
    JsonApiClient client;
    HttpServer server;

    setUp(() async {
      server = await HttpServer.bind(host, port);
      httpClient = Client();
      client = JsonApiClient(DartHttp(httpClient), routing);
      unawaited(server.forEach(serverHandler));
    });

    tearDown(() async {
      httpClient.close();
      await server.close();
    });

    test('Happy Path', () async {
      await client.createResource('writers', '1',
          attributes: {'name': 'Martin Fowler'});
      await client
          .createResource('books', '2', attributes: {'title': 'Refactoring'});
      await client.updateResource('books', '2', many: {'authors': []});
      await client
          .addMany('books', '2', 'authors', [Identifier('writers', '1')]);

      final response =
          await client.fetchResource('books', '2', include: ['authors']);

      expect(response.resource.attributes['title'], 'Refactoring');
      expect(response.included.first.attributes['name'], 'Martin Fowler');
    });
  }, testOn: 'vm');
}
