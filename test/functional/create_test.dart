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
    /// If a POST query did not include a Client-Generated ID and the requested
    /// resource has been created successfully, the server MUST return a 201 Created status code.
    ///
    /// The response SHOULD include a Location header identifying the location of the newly created resource.
    ///
    /// The response MUST also include a document that contains the primary resource created.
    ///
    /// If the resource object returned by the response contains a self key in its links member
    /// and a Location header is provided, the value of the self member MUST match the value of the Location header.
    ///
    /// https://jsonapi.org/format/#crud-creating-responses-201
    test('201 Created', () async {
      final newYork =
          Resource('cities', null, attributes: {'name': 'New York'});
      final r0 =
          await client.createResource(urlDesign.collection('cities'), newYork);

      expect(r0.status, 201);
      expect(r0.isSuccessful, true);
      expect(r0.data.unwrap().id, isNotEmpty);
      expect(r0.data.unwrap().type, 'cities');
      expect(r0.data.unwrap().attributes['name'], 'New York');
      expect(r0.location, isNotNull);

      // Make sure the resource is available
      final r1 = await client
          .fetchResource(urlDesign.resource('cities', r0.data.unwrap().id));
      expect(r1.data.resourceObject.attributes['name'], 'New York');
    });

    /// If a query to create a resource has been accepted for processing,
    /// but the processing has not been completed by the time the server responds,
    /// the server MUST return a 202 Accepted status code.
    ///
    /// https://jsonapi.org/format/#crud-creating-responses-202
//    test('202 Accepted', () async {
//      final roadster2020 =
//          Resource('models', null, attributes: {'name': 'Roadster 2020'});
//      final r0 = await client.createResource(
//          urlDesign.collection('models'), roadster2020,
//          headers: {'Prefer': 'return-asynch'});
//
//      expect(r0.status, 202);
//      expect(r0.isSuccessful, false); // neither success
//      expect(r0.isFailed, false); // nor failure yet
//      expect(r0.isAsync, true); // yay async!
//      expect(r0.document, isNull);
//      expect(r0.asyncDocument, isNotNull);
//      expect(r0.asyncData.unwrap().type, 'jobs');
//      expect(r0.location, isNull);
//      expect(r0.contentLocation, isNotNull);
//
//      final r1 = await client.fetchResource(r0.contentLocation);
//      expect(r1.status, 200);
//      expect(r1.data.unwrap().type, 'jobs');
//
//      await Future.delayed(Duration(milliseconds: 100));
//
//      // When it's done, this will be the created resource
//      final r2 = await client.fetchResource(r0.contentLocation);
//      expect(r2.data.unwrap().type, 'models');
//      expect(r2.data.unwrap().attributes['name'], 'Roadster 2020');
//    });

    /// If a POST query did include a Client-Generated ID and the requested
    /// resource has been created successfully, the server MUST return either
    /// a 201 Created status code and response document (as described above)
    /// or a 204 No Content status code with no response document.
    ///
    /// https://jsonapi.org/format/#crud-creating-responses-204
    test('204 No Content', () async {
      final newYork =
          Resource('cities', '555', attributes: {'name': 'New York'});
      final r0 =
          await client.createResource(urlDesign.collection('cities'), newYork);

      expect(r0.status, 204);
      expect(r0.isSuccessful, true);
      expect(r0.document, isNull);

      // Make sure the resource is available
      final r1 =
          await client.fetchResource(urlDesign.resource('cities', '555'));
      expect(r1.data.unwrap().attributes['name'], 'New York');
    });

    /// A server MUST return 409 Conflict when processing a POST query to
    /// create a resource with a client-generated ID that already exists.
    ///
    /// https://jsonapi.org/format/#crud-creating-responses-409
    test('409 Conflict - Resource already exists', () async {
      final newYork = Resource('cities', '1', attributes: {'name': 'New York'});
      final r0 =
          await client.createResource(urlDesign.collection('cities'), newYork);

      expect(r0.isSuccessful, true);

      final r1 =
          await client.createResource(urlDesign.collection('cities'), newYork);

      expect(r1.status, 409);
      expect(r1.isSuccessful, false);
      expect(r1.document.errors.first.detail, 'Resource already exists');
    });

    /// A server MUST return 409 Conflict when processing a POST query in
    /// which the resource object’s type is not among the type(s) that
    /// constitute the collection represented by the endpoint.
    ///
    /// https://jsonapi.org/format/#crud-creating-responses-409
    test('409 Conflict - Incompatible type', () async {
      final newYork =
          Resource('cities', '555', attributes: {'name': 'New York'});
      final r0 = await client.createResource(
          urlDesign.collection('companies'), newYork);

      expect(r0.status, 409);
      expect(r0.isSuccessful, false);
      expect(r0.document.errors.first.detail, 'Incompatible type');
    });
  }, testOn: 'vm');
}
