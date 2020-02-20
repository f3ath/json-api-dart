import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';
import 'package:test/test.dart';

void main() {
  final routing = StandardRouting(Uri.parse('http://example.com'));
  final server = JsonApiServer(RepositoryController(InMemoryRepository({})));

  group('JsonApiServer', () {
    test('returns `bad request` on incomplete relationship', () async {
      final rq = HttpRequest(
          'PATCH', routing.relationship('books', '1', 'author'),
          body: '{}');
      final rs = await server(rq);
      expect(rs.statusCode, 400);
      final error = Document.fromJson(json.decode(rs.body), null).errors.first;
      expect(error.status, '400');
      expect(error.title, 'Bad request');
      expect(error.detail, 'Incomplete relationship object');
    });

    test('returns `bad request` when payload is not a valid JSON', () async {
      final rq =
          HttpRequest('POST', routing.collection('books'), body: '"ololo"abc');
      final rs = await server(rq);
      expect(rs.statusCode, 400);
      final error = Document.fromJson(json.decode(rs.body), null).errors.first;
      expect(error.status, '400');
      expect(error.title, 'Bad request');
      expect(error.detail, startsWith('Invalid JSON. '));
    });

    test('returns `bad request` when payload is not a valid JSON:API object',
        () async {
      final rq =
          HttpRequest('POST', routing.collection('books'), body: '"oops"');
      final rs = await server(rq);
      expect(rs.statusCode, 400);
      final error = Document.fromJson(json.decode(rs.body), null).errors.first;
      expect(error.status, '400');
      expect(error.title, 'Bad request');
      expect(error.detail,
          "A JSON:API resource document must be a JSON object and contain the 'data' member");
    });

    test('returns `bad request` when payload violates JSON:API', () async {
      final rq = HttpRequest('POST', routing.collection('books'),
          body: '{"data": {}}');
      final rs = await server(rq);
      expect(rs.statusCode, 400);
      final error = Document.fromJson(json.decode(rs.body), null).errors.first;
      expect(error.status, '400');
      expect(error.title, 'Bad request');
      expect(error.detail, "Resource 'type' must not be null");
    });

    test('returns `not found` if URI is not recognized', () async {
      final rq = HttpRequest('GET', Uri.parse('http://localhost/a/b/c/d/e'));
      final rs = await server(rq);
      expect(rs.statusCode, 404);
      final error = Document.fromJson(json.decode(rs.body), null).errors.first;
      expect(error.status, '404');
      expect(error.title, 'Not Found');
      expect(error.detail, 'The requested URL does exist on the server');
    });

    test('returns `method not allowed` for resource collection', () async {
      final rq = HttpRequest('DELETE', routing.collection('books'));
      final rs = await server(rq);
      expect(rs.statusCode, 405);
      expect(rs.headers['allow'], 'GET, POST');
      final error = Document.fromJson(json.decode(rs.body), null).errors.first;
      expect(error.status, '405');
      expect(error.title, 'Method Not Allowed');
      expect(error.detail, 'Allowed methods: GET, POST');
    });

    test('returns `method not allowed` for resource', () async {
      final rq = HttpRequest('POST', routing.resource('books', '1'));
      final rs = await server(rq);
      expect(rs.statusCode, 405);
      expect(rs.headers['allow'], 'DELETE, GET, PATCH');
      final error = Document.fromJson(json.decode(rs.body), null).errors.first;
      expect(error.status, '405');
      expect(error.title, 'Method Not Allowed');
      expect(error.detail, 'Allowed methods: DELETE, GET, PATCH');
    });

    test('returns `method not allowed` for related', () async {
      final rq = HttpRequest('POST', routing.related('books', '1', 'author'));
      final rs = await server(rq);
      expect(rs.statusCode, 405);
      expect(rs.headers['allow'], 'GET');
      final error = Document.fromJson(json.decode(rs.body), null).errors.first;
      expect(error.status, '405');
      expect(error.title, 'Method Not Allowed');
      expect(error.detail, 'Allowed methods: GET');
    });

    test('returns `method not allowed` for relationship', () async {
      final rq =
          HttpRequest('PUT', routing.relationship('books', '1', 'author'));
      final rs = await server(rq);
      expect(rs.statusCode, 405);
      expect(rs.headers['allow'], 'DELETE, GET, PATCH, POST');
      final error = Document.fromJson(json.decode(rs.body), null).errors.first;
      expect(error.status, '405');
      expect(error.title, 'Method Not Allowed');
      expect(error.detail, 'Allowed methods: DELETE, GET, PATCH, POST');
    });
  });
}
