import 'dart:io';

import 'package:json_api/client.dart';
import 'package:json_api/query.dart';
import 'package:json_api/server.dart';
import 'package:json_api/uri_design.dart';
import 'package:shelf/shelf_io.dart';
import 'package:test/test.dart';

import '../../../example/server/controller/sorting_controller.dart';
import '../../../example/server/shelf_request_response_converter.dart';

/// Sorting
void main() async {
  HttpServer server;
  UriAwareClient client;
  final host = 'localhost';
  final port = 8083;
  final base = Uri(scheme: 'http', host: host, port: port);
  final design = UriDesign.standard(base);

  setUp(() async {
    client = UriAwareClient(design);
    final handler = RequestHandler(
        ShelfRequestResponseConverter(), SortingController(), design);

    server = await serve(handler, host, port);
  });

  tearDown(() async {
    client.close();
    await server.close();
  });

  group('Sorting a collection', () {
    test('unsorted', () async {
      final r = await client.fetchCollection('names');
      expect(r.data.unwrap().length, 16);
      expect(r.data.unwrap().first.attributes['firstName'], 'Emma');
      expect(r.data.unwrap().first.attributes['lastName'], 'Smith');
      expect(r.data.unwrap().last.attributes['firstName'], 'Noah');
      expect(r.data.unwrap().last.attributes['lastName'], 'Brown');
    });

    test('sort by firstName ASC', () async {
      final r = await client.fetchCollection('names',
          parameters: Sort([Asc('firstName')]));
      expect(r.data.unwrap().length, 16);
      expect(r.data.unwrap().first.attributes['firstName'], 'Emma');
      expect(r.data.unwrap().first.attributes['lastName'], 'Smith');
      expect(r.data.unwrap().last.attributes['firstName'], 'Olivia');
      expect(r.data.unwrap().last.attributes['lastName'], 'Brown');
    });

    test('sort by lastName DESC', () async {
      final r = await client.fetchCollection('names',
          parameters: Sort([Desc('lastName')]));
      expect(r.data.unwrap().length, 16);
      expect(r.data.unwrap().first.attributes['firstName'], 'Emma');
      expect(r.data.unwrap().first.attributes['lastName'], 'Williams');
      expect(r.data.unwrap().last.attributes['firstName'], 'Noah');
      expect(r.data.unwrap().last.attributes['lastName'], 'Brown');
    });

    test('sort by fistName DESC, lastName ASC', () async {
      final r = await client.fetchCollection('names',
          parameters: Sort([Desc('firstName'), Asc('lastName')]));
      expect(r.data.unwrap().length, 16);
      expect(r.data.unwrap()[0].attributes['firstName'], 'Olivia');
      expect(r.data.unwrap()[0].attributes['lastName'], 'Brown');
      expect(r.data.unwrap()[1].attributes['firstName'], 'Olivia');
      expect(r.data.unwrap()[1].attributes['lastName'], 'Johnson');
      expect(r.data.unwrap()[2].attributes['firstName'], 'Olivia');
      expect(r.data.unwrap()[2].attributes['lastName'], 'Smith');
      expect(r.data.unwrap()[3].attributes['firstName'], 'Olivia');
      expect(r.data.unwrap()[3].attributes['lastName'], 'Williams');

      expect(r.data.unwrap().last.attributes['firstName'], 'Emma');
      expect(r.data.unwrap().last.attributes['lastName'], 'Williams');
    });
  }, testOn: 'vm');
}
