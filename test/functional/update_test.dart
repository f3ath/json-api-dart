import 'dart:io';

import 'package:http/http.dart';
import 'package:json_api/json_api.dart';
import 'package:json_api/server.dart';
import 'package:test/test.dart';

import '../../example/cars_server.dart';

void main() async {
  HttpServer server;
  Client httpClient;
  JsonApiClient client;
  final port = 8084;
  final urlDesign = PathBasedUrlDesign(Uri.parse('http://localhost:$port'));

  setUp(() async {
    httpClient = Client();
    client = JsonApiClient(httpClient);
    server = await createServer(InternetAddress.loopbackIPv4, port);
  });

  tearDown(() async {
    httpClient.close();
    await server.close();
  });

  /// Updating a Resource’s Attributes
  /// ================================
  ///
  /// Any or all of a resource’s attributes MAY be included
  /// in the resource object included in a PATCH query.
  ///
  /// If a query does not include all of the attributes for a resource,
  /// the server MUST interpret the missing attributes as if they were
  /// included with their current values. The server MUST NOT interpret
  /// missing attributes as null values.
  ///
  /// Updating a Resource’s Relationships
  /// ===================================
  ///
  /// Any or all of a resource’s relationships MAY be included
  /// in the resource object included in a PATCH query.
  ///
  /// If a query does not include all of the relationships for a resource,
  /// the server MUST interpret the missing relationships as if they were
  /// included with their current values. It MUST NOT interpret them
  /// as null or empty values.
  ///
  /// If a relationship is provided in the relationships member
  /// of a resource object in a PATCH query, its value MUST be
  /// a relationship object with a data member.
  /// The relationship’s value will be replaced with the value specified in this member.
  group('resource', () {
    /// If a server accepts an update but also changes the resource(s)
    /// in ways other than those specified by the query (for example,
    /// updating the updated-at attribute or a computed sha),
    /// it MUST return a 200 OK response.
    ///
    /// The response document MUST include a representation of the
    /// updated resource(s) as if a GET query was made to the query URL.
    ///
    /// A server MUST return a 200 OK status code if an update is successful,
    /// the client’s current attributes remain up to date, and the server responds
    /// only with top-level meta data. In this case the server MUST NOT include
    /// a representation of the updated resource(s).
    ///
    /// https://jsonapi.org/format/#crud-updating-responses-200
    test('200 OK', () async {
      final r0 =
          await client.fetchResource(urlDesign.resource('companies', '1'));
      final original = r0.document.data.unwrap();

      expect(original.attributes['name'], 'Tesla');
      expect(original.attributes['nasdaq'], isNull);
      expect(original.toMany['models'].length, 4);

      original.attributes['nasdaq'] = 'TSLA';
      original.attributes.remove('name'); // Not changing this
      original.toMany['models'].removeLast();
      original.toOne['headquarters'] = null; // should be removed

      final r1 = await client.updateResource(
          urlDesign.resource('companies', '1'), original);
      final updated = r1.document.data.unwrap();

      expect(r1.status, 200);
      expect(updated.attributes['name'], 'Tesla');
      expect(updated.attributes['nasdaq'], 'TSLA');
      expect(updated.toMany['models'].length, 3);
      expect(updated.toOne['headquarters'], isNull);
      expect(
          updated.attributes['updatedAt'] != original.attributes['updatedAt'],
          true);
    });

    /// If an update is successful and the server doesn’t update any attributes
    /// besides those provided, the server MUST return either
    /// a 200 OK status code and response document (as described above)
    /// or a 204 No Content status code with no response document.
    ///
    /// https://jsonapi.org/format/#crud-updating-responses-204
    test('204 No Content', () async {
      final r0 = await client.fetchResource(urlDesign.resource('models', '3'));
      final original = r0.document.data.unwrap();

      expect(original.attributes['name'], 'Model X');

      original.attributes['name'] = 'Model XXX';

      final r1 = await client.updateResource(
          urlDesign.resource('models', '3'), original);
      expect(r1.status, 204);
      expect(r1.document, isNull);

      final r2 = await client.fetchResource(urlDesign.resource('models', '3'));

      expect(r2.data.unwrap().attributes['name'], 'Model XXX');
    });

    /// A server MAY return 409 Conflict when processing a PATCH query
    /// to update a resource if that update would violate other
    /// server-enforced constraints (such as a uniqueness constraint
    /// on a property other than id).
    ///
    /// A server MUST return 409 Conflict when processing a PATCH query
    /// in which the resource object’s type and id do not match the server’s endpoint.
    ///
    /// https://jsonapi.org/format/#crud-updating-responses-409
    test('409 Conflict - Endpoint mismatch', () async {
      final r0 = await client.fetchResource(urlDesign.resource('models', '3'));
      final original = r0.document.data.unwrap();

      final r1 = await client.updateResource(
          urlDesign.resource('companies', '1'), original);
      expect(r1.status, 409);
      expect(r1.document.errors.first.detail, 'Incompatible type');
    });
  }, testOn: 'vm');

  /// Updating Relationships
  /// ======================
  ///
  /// Although relationships can be modified along with resources (as described above),
  /// JSON:API also supports updating of relationships independently at URLs from relationship links.
  ///
  /// Note: Relationships are updated without exposing the underlying server semantics,
  /// such as foreign keys. Furthermore, relationships can be updated without necessarily
  /// affecting the related resources. For example, if an article has many authors,
  /// it is possible to remove one of the authors from the article without deleting the person itself.
  /// Similarly, if an article has many tags, it is possible to add or remove tags.
  /// Under the hood on the server, the first of these examples
  /// might be implemented with a foreign key, while the second
  /// could be implemented with a join table, but the JSON:API protocol would be the same in both cases.
  ///
  /// Note: A server may choose to delete the underlying resource
  /// if a relationship is deleted (as a garbage collection measure).
  ///
  /// https://jsonapi.org/format/#crud-updating-relationships
  group('relationship', () {
    /// Updating To-One Relationships
    /// =============================
    ///
    /// A server MUST respond to PATCH requests to a URL from a to-one
    /// relationship link as described below.
    ///
    /// The PATCH query MUST include a top-level member named data containing one of:
    ///   - a resource identifier object corresponding to the new related resource.
    ///   - null, to remove the relationship.
    group('to-one', () {
      group('replace', () {
        test('204 No Content', () async {
          final relationship = urlDesign.relationship('companies', '1', 'hq');
          final r0 = await client.fetchToOne(relationship);
          final original = r0.document.data.unwrap();
          expect(original.id, '2');

          final r1 = await client.replaceToOne(
              relationship, Identifier(original.type, '1'));
          expect(r1.status, 204);

          final r2 = await client.fetchToOne(relationship);
          final updated = r2.document.data.unwrap();
          expect(updated.type, original.type);
          expect(updated.id, '1');
        });
      });

      group('remove', () {
        test('204 No Content', () async {
          final relationship = urlDesign.relationship('companies', '1', 'hq');

          final r0 = await client.fetchToOne(relationship);
          final original = r0.document.data.unwrap();
          expect(original.id, '2');

          final r1 = await client.deleteToOne(relationship);
          expect(r1.status, 204);

          final r2 = await client.fetchToOne(relationship);
          expect(r2.document.data.unwrap(), isNull);
        });
      });
    }, testOn: 'vm');

    /// Updating To-Many Relationships
    /// ==============================
    ///
    /// A server MUST respond to PATCH, POST, and DELETE requests to a URL
    /// from a to-many relationship link as described below.
    ///
    /// For all query types, the body MUST contain a data member
    /// whose value is an empty array or an array of resource identifier objects.
    group('to-many', () {
      /// If a client makes a PATCH query to a URL from a to-many relationship link,
      /// the server MUST either completely replace every member of the relationship,
      /// return an appropriate error response if some resources can not be
      /// found or accessed, or return a 403 Forbidden response if complete replacement
      /// is not allowed by the server.
      group('replace', () {
        test('204 No Content', () async {
          final relationship =
              urlDesign.relationship('companies', '1', 'models');
          final r0 = await client.fetchToMany(relationship);
          final original = r0.data.identifiers.map((_) => _.id);
          expect(original, ['1', '2', '3', '4']);

          final r1 = await client.replaceToMany(relationship,
              [Identifier('models', '5'), Identifier('models', '6')]);
          expect(r1.status, 204);

          final r2 = await client.fetchToMany(relationship);
          final updated = r2.data.identifiers.map((_) => _.id);
          expect(updated, ['5', '6']);
        });
      });

      /// If a client makes a POST query to a URL from a relationship link,
      /// the server MUST add the specified members to the relationship
      /// unless they are already present.
      /// If a given type and id is already in the relationship, the server MUST NOT add it again.
      ///
      /// Note: This matches the semantics of databases that use foreign keys
      /// for has-many relationships. Document-based storage should check
      /// the has-many relationship before appending to avoid duplicates.
      ///
      /// If all of the specified resources can be added to, or are already present in,
      /// the relationship then the server MUST return a successful response.
      ///
      /// Note: This approach ensures that a query is successful if the server’s state
      /// matches the requested state, and helps avoid pointless race conditions
      /// caused by multiple clients making the same changes to a relationship.
      group('add', () {
        test('200 OK', () async {
          final models = urlDesign.relationship('companies', '1', 'models');
          final r0 = await client.fetchToMany(models);
          final original = r0.data.identifiers.map((_) => _.id);
          expect(original, ['1', '2', '3', '4']);

          final r1 = await client.addToMany(
              models, [Identifier('models', '1'), Identifier('models', '5')]);
          expect(r1.status, 200);

          final updated = r1.data.identifiers.map((_) => _.id);
          expect(updated, ['1', '2', '3', '4', '5']);
        });
      });
    });
  }, testOn: 'vm');
}
