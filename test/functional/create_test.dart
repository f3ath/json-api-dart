import 'dart:async';
import 'dart:io';

import 'package:json_api/json_api.dart';
import 'package:json_api_document/json_api_document.dart';
import 'package:json_api_server/json_api_server.dart';
import 'package:test/test.dart';

import '../../example/cars_server.dart';

void main() async {
  HttpServer server;
  final client = JsonApiClient();
  final route = Routing(Uri.parse('http://localhost:8080'));
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
      final newYork =
          Resource('cities', null, attributes: {'name': 'New York'});
      final r0 =
          await client.createResource(route.collection('cities'), newYork);

      expect(r0.status, 201);
      expect(r0.isSuccessful, true);
      expect(r0.data.toResource().id, isNotEmpty);
      expect(r0.data.toResource().type, 'cities');
      expect(r0.data.toResource().attributes['name'], 'New York');
      expect(r0.location, isNotNull);

      // Make sure the resource is available
      final r1 = await client
          .fetchResource(route.resource('cities', r0.data.toResource().id));
      expect(r1.data.resourceObject.attributes['name'], 'New York');
    });

    /// If a request to create a resource has been accepted for processing,
    /// but the processing has not been completed by the time the server responds,
    /// the server MUST return a 202 Accepted status code.
    ///
    /// https://jsonapi.org/format/#crud-creating-responses-202
    test('202 Acepted', () async {
      final roadster2020 =
          Resource('models', null, attributes: {'name': 'Roadster 2020'});
      final r0 =
          await client.createResource(route.collection('models'), roadster2020);

      expect(r0.status, 202);
      expect(r0.isSuccessful, false); // neither success
      expect(r0.isFailed, false); // nor failure yet
      expect(r0.isAsync, true); // yay async!
      expect(r0.document, isNull);
      expect(r0.asyncDocument, isNotNull);
      expect(r0.asyncData.toResource().type, 'jobs');
      expect(r0.location, isNull);
      expect(r0.contentLocation, isNotNull);

      final r1 = await client.fetchResource(r0.contentLocation);
      expect(r1.status, 200);
      expect(r1.data.toResource().type, 'jobs');

      await Future.delayed(Duration(milliseconds: 100));

      // When it's done, this will be the created resource
      final r2 = await client.fetchResource(r0.contentLocation);
      expect(r2.data.toResource().type, 'models');
      expect(r2.data.toResource().attributes['name'], 'Roadster 2020');
    });

    /// If a POST request did include a Client-Generated ID and the requested
    /// resource has been created successfully, the server MUST return either
    /// a 201 Created status code and response document (as described above)
    /// or a 204 No Content status code with no response document.
    ///
    /// https://jsonapi.org/format/#crud-creating-responses-204
    test('204 No Content', () async {
      final newYork =
          Resource('cities', '555', attributes: {'name': 'New York'});
      final r0 =
          await client.createResource(route.collection('cities'), newYork);

      expect(r0.status, 204);
      expect(r0.isSuccessful, true);
      expect(r0.document, isNull);

      // Make sure the resource is available
      final r1 = await client.fetchResource(route.resource('cities', '555'));
      expect(r1.data.toResource().attributes['name'], 'New York');
    });

    /// A server MUST return 409 Conflict when processing a POST request to
    /// create a resource with a client-generated ID that already exists.
    ///
    /// https://jsonapi.org/format/#crud-creating-responses-409
    test('409 Conflict - Resource already exists', () async {
      final newYork = Resource('cities', '1', attributes: {'name': 'New York'});
      final r0 =
          await client.createResource(route.collection('cities'), newYork);

      expect(r0.status, 409);
      expect(r0.isSuccessful, false);
      expect(r0.document.errors.first.detail, 'Resource already exists');
    });

    /// A server MUST return 409 Conflict when processing a POST request in
    /// which the resource object’s type is not among the type(s) that
    /// constitute the collection represented by the endpoint.
    ///
    /// https://jsonapi.org/format/#crud-creating-responses-409
    test('409 Conflict - Incompatible type', () async {
      final newYork =
          Resource('cities', '555', attributes: {'name': 'New York'});
      final r0 =
          await client.createResource(route.collection('companies'), newYork);

      expect(r0.status, 409);
      expect(r0.isSuccessful, false);
      expect(r0.document.errors.first.detail, 'Incompatible type');
    });
  }, testOn: 'vm');
}
