@TestOn('vm')
import 'dart:io';

import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
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
    /// If a POST request did not include a Client-Generated ID and the requested
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
      final modelY = Resource('models', null, attributes: {'name': 'Model Y'});
      final r0 = await client.createResource(Url.collection('models'), modelY);

      expect(r0.status, 201);
      expect(r0.isSuccessful, true);
      expect(r0.document.data.id, isNotEmpty);
      expect(r0.document.data.type, 'models');
      expect(r0.document.data.attributes['name'], 'Model Y');
      expect(r0.location, isNotEmpty);

      // Make sure the resource is available
      final r1 = await client
          .fetchResource(Url.resource('models', r0.document.data.id));
      expect(r1.document.data.attributes['name'], 'Model Y');
    });

    /// If a POST request did include a Client-Generated ID and the requested
    /// resource has been created successfully, the server MUST return either
    /// a 201 Created status code and response document (as described above)
    /// or a 204 No Content status code with no response document.
    ///
    /// https://jsonapi.org/format/#crud-creating-responses-204
    test('204 No Content', () async {
      final modelY = Resource('models', '555', attributes: {'name': 'Model Y'});
      final r0 = await client.createResource(Url.collection('models'), modelY);

      expect(r0.status, 204);
      expect(r0.isSuccessful, true);
      expect(r0.document, isNull);

      // Make sure the resource is available
      final r1 = await client.fetchResource(Url.resource('models', '555'));
      expect(r1.document.data.attributes['name'], 'Model Y');
    });

    /// A server MUST return 409 Conflict when processing a POST request to
    /// create a resource with a client-generated ID that already exists.
    ///
    /// https://jsonapi.org/format/#crud-creating-responses-409
    test('409 Conflict - Resource already exists', () async {
      final modelY = Resource('models', '1', attributes: {'name': 'Model Y'});
      final r0 = await client.createResource(Url.collection('models'), modelY);

      expect(r0.status, 409);
      expect(r0.isSuccessful, false);
      expect(r0.document.isError, true);
      expect(r0.document.errors.first.detail, 'Resource already exists');
    });

    /// A server MUST return 409 Conflict when processing a POST request in
    /// which the resource object’s type is not among the type(s) that
    /// constitute the collection represented by the endpoint.
    ///
    /// https://jsonapi.org/format/#crud-creating-responses-409
    test('409 Conflict - Incompatible type', () async {
      final modelY = Resource('models', '555', attributes: {'name': 'Model Y'});
      final r0 =
          await client.createResource(Url.collection('companies'), modelY);

      expect(r0.status, 409);
      expect(r0.isSuccessful, false);
      expect(r0.document.isError, true);
      expect(r0.document.errors.first.detail, 'Incompatible type');
    });
  });
}
