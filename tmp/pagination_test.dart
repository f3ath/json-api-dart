import 'dart:io';

import 'package:json_api/client.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/server/pagination.dart';
import 'package:json_api/uri_design.dart';
import 'package:shelf/shelf_io.dart';
import 'package:test/test.dart';

import '../../../example/server/controller/paginating_controller.dart';
import '../../../example/server/shelf_request_response_converter.dart';

/// Pagination
void main() async {
  HttpServer server;
  JsonApiClient client;
  final host = 'localhost';
  final port = 8082;
  final base = Uri(scheme: 'http', host: host, port: port);
  final design = UriDesign.standard(base);

  setUp(() async {
    client = JsonApiClient();
    final pagination = Pagination.fixedSize(5);
    final handler = RequestHandler(ShelfRequestResponseConverter(),
        PaginatingController(pagination), design,
        pagination: pagination);

    server = await serve(handler, host, port);
  });

  tearDown(() async {
    client.close();
    await server.close();
  });

  group('Paginating', () {
    test('a primary collection', () async {
      final r0 =
          await client.fetchCollection(base.replace(pathSegments: ['colors']));
      expect(r0.data.unwrap().length, 5);
      expect(r0.data.unwrap().first.attributes['name'], 'black');
      expect(r0.data.unwrap().last.attributes['name'], 'maroon');

      final r1 = await client.fetchCollection(r0.data.next.uri);
      expect(r1.data.unwrap().length, 5);
      expect(r1.data.unwrap().first.attributes['name'], 'red');
      expect(r1.data.unwrap().last.attributes['name'], 'lime');

      final r2 = await client.fetchCollection(r0.data.last.uri);
      expect(r2.data.unwrap().length, 1);
      expect(r2.data.unwrap().first.attributes['name'], 'aqua');

      final r3 = await client.fetchCollection(r2.data.prev.uri);
      expect(r3.data.unwrap().length, 5);
      expect(r3.data.unwrap().first.attributes['name'], 'olive');
      expect(r3.data.unwrap().last.attributes['name'], 'teal');
    });
  }, testOn: 'vm');
}
