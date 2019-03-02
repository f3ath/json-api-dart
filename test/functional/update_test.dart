@TestOn('vm')
import 'dart:io';

import 'package:json_api/client.dart';
import 'package:json_api/src/server/simple_server.dart';
import 'package:test/test.dart';

import '../../example/cars_server.dart';

/// Updating a Resource’s Attributes
/// ================================
///
/// Any or all of a resource’s attributes MAY be included
/// in the resource object included in a PATCH request.
///
/// If a request does not include all of the attributes for a resource,
/// the server MUST interpret the missing attributes as if they were
/// included with their current values. The server MUST NOT interpret
/// missing attributes as null values.
///
/// Updating a Resource’s Relationships
/// ===================================
///
/// Any or all of a resource’s relationships MAY be included
/// in the resource object included in a PATCH request.
///
/// If a request does not include all of the relationships for a resource,
/// the server MUST interpret the missing relationships as if they were
/// included with their current values. It MUST NOT interpret them
/// as null or empty values.
///
/// If a relationship is provided in the relationships member
/// of a resource object in a PATCH request, its value MUST be
/// a relationship object with a data member.
/// The relationship’s value will be replaced with the value specified in this member.
void main() async {
  final client = JsonApiClient();
  SimpleServer s;
  setUp(() async {
    s = createServer();
    return await s.start(InternetAddress.loopbackIPv4, 8080);
  });

  tearDown(() => s.stop());

  group('resource', () {

    /// If a server accepts an update but also changes the resource(s)
    /// in ways other than those specified by the request (for example,
    /// updating the updated-at attribute or a computed sha),
    /// it MUST return a 200 OK response.
    ///
    /// The response document MUST include a representation of the
    /// updated resource(s) as if a GET request was made to the request URL.
    test('200 OK', () async {
      final r0 = await client.fetchResource(Url.resource('companies', '1'));
      final original = r0.document.resourceObject.toResource();

      expect(original.attributes['name'], 'Tesla');
      expect(original.attributes['nasdaq'], isNull);
      expect(original.toMany['models'].length, 4);

      original.attributes['nasdaq'] = 'TSLA';
      original.attributes.remove('name'); // Not changing this
      original.toMany['models'].removeLast();
      original.toOne.clear(); // Not changing these

      final r1 = await client.updateResource(Url.resource('companies', '1'), original);
      final updated = r1.document.resourceObject.toResource();

      expect(r1.status, 200);
      expect(updated.attributes['name'], 'Tesla');
      expect(updated.attributes['nasdaq'], 'TSLA');
      expect(updated.toMany['models'].length, 3);
    });

    test('204 No Content', () async {
      final r0 = await client.fetchResource(Url.resource('models', '3'));
      final original = r0.document.resourceObject.toResource();

      expect(original.attributes['name'], 'Model X');

      original.attributes['name'] = 'Model XXX';

      final r1 = await client.updateResource(Url.resource('models', '3'), original);
      expect(r1.status, 204);
      expect(r1.document, isNull);

      final r2 = await client.fetchResource(Url.resource('models', '3'));

      expect(r2.document.resourceObject.attributes['name'], 'Model XXX');
    });

  });
}
