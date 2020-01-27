import 'dart:async';
import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/server.dart';
import 'package:json_api/uri_design.dart';
import 'package:test/test.dart';

void main() {
  final base = Uri.parse('http://localhost');
  var uriDesign = UriDesign.standard(base);
  final handler = RequestHandler(TestAdapter(), DummyController(), uriDesign);

  group('HTTP Handler', () {
    test('returns `bad request` on incomplete relationship', () async {
      final rq = TestRequest(
          uriDesign.relationshipUri('books', '1', 'author'), 'PATCH', '{}');
      final rs = await handler.call(rq);
      expect(rs.statusCode, 400);
      final error = Document.fromJson(json.decode(rs.body), null).errors.first;
      expect(error.status, '400');
      expect(error.title, 'Bad request');
      expect(error.detail, 'Incomplete relationship object');
    });

    test('returns `bad request` when payload is not a valid JSON', () async {
      final rq =
          TestRequest(uriDesign.collectionUri('books'), 'POST', '"ololo"abc');
      final rs = await handler.call(rq);
      expect(rs.statusCode, 400);
      final error = Document.fromJson(json.decode(rs.body), null).errors.first;
      expect(error.status, '400');
      expect(error.title, 'Bad request');
      expect(error.detail, startsWith('Invalid JSON. '));
    });

    test('returns `bad request` when payload is not a valid JSON:API object',
        () async {
      final rq =
          TestRequest(uriDesign.collectionUri('books'), 'POST', '"oops"');
      final rs = await handler.call(rq);
      expect(rs.statusCode, 400);
      final error = Document.fromJson(json.decode(rs.body), null).errors.first;
      expect(error.status, '400');
      expect(error.title, 'Bad request');
      expect(error.detail,
          "A JSON:API resource document must be a JSON object and contain the 'data' member");
    });

    test('returns `bad request` when payload violates JSON:API', () async {
      final rq =
          TestRequest(uriDesign.collectionUri('books'), 'POST', '{"data": {}}');
      final rs = await handler.call(rq);
      expect(rs.statusCode, 400);
      final error = Document.fromJson(json.decode(rs.body), null).errors.first;
      expect(error.status, '400');
      expect(error.title, 'Bad request');
      expect(error.detail, "Resource 'type' must not be null");
    });

    test('returns `not found` if URI is not recognized', () async {
      final rq =
          TestRequest(Uri.parse('http://localhost/a/b/c/d/e'), 'GET', '');
      final rs = await handler.call(rq);
      expect(rs.statusCode, 404);
      final error = Document.fromJson(json.decode(rs.body), null).errors.first;
      expect(error.status, '404');
      expect(error.title, 'Not Found');
      expect(error.detail, 'The requested URL does exist on the server');
    });

    test('returns `method not allowed` for resource collection', () async {
      final rq = TestRequest(uriDesign.collectionUri('books'), 'DELETE', '');
      final rs = await handler.call(rq);
      expect(rs.statusCode, 405);
      expect(rs.headers['Allow'], 'GET, POST');
      final error = Document.fromJson(json.decode(rs.body), null).errors.first;
      expect(error.status, '405');
      expect(error.title, 'Method Not Allowed');
      expect(error.detail, 'Allowed methods: GET, POST');
    });

    test('returns `method not allowed` for resource ', () async {
      final rq = TestRequest(uriDesign.resourceUri('books', '1'), 'POST', '');
      final rs = await handler.call(rq);
      expect(rs.statusCode, 405);
      expect(rs.headers['Allow'], 'DELETE, GET, PATCH');
      final error = Document.fromJson(json.decode(rs.body), null).errors.first;
      expect(error.status, '405');
      expect(error.title, 'Method Not Allowed');
      expect(error.detail, 'Allowed methods: DELETE, GET, PATCH');
    });

    test('returns `method not allowed` for related ', () async {
      final rq =
          TestRequest(uriDesign.relatedUri('books', '1', 'author'), 'POST', '');
      final rs = await handler.call(rq);
      expect(rs.statusCode, 405);
      expect(rs.headers['Allow'], 'GET');
      final error = Document.fromJson(json.decode(rs.body), null).errors.first;
      expect(error.status, '405');
      expect(error.title, 'Method Not Allowed');
      expect(error.detail, 'Allowed methods: GET');
    });

    test('returns `method not allowed` for relationship ', () async {
      final rq = TestRequest(
          uriDesign.relationshipUri('books', '1', 'author'), 'PUT', '');
      final rs = await handler.call(rq);
      expect(rs.statusCode, 405);
      expect(rs.headers['Allow'], 'DELETE, GET, PATCH, POST');
      final error = Document.fromJson(json.decode(rs.body), null).errors.first;
      expect(error.status, '405');
      expect(error.title, 'Method Not Allowed');
      expect(error.detail, 'Allowed methods: DELETE, GET, PATCH, POST');
    });
  });
}

class TestAdapter implements HttpAdapter<TestRequest, TestResponse> {
  @override
  FutureOr<TestResponse> createResponse(
          int statusCode, String body, Map<String, String> headers) =>
      TestResponse(statusCode, body, headers);

  @override
  FutureOr<String> getBody(TestRequest request) => request.body;

  @override
  FutureOr<String> getMethod(TestRequest request) => request.method;

  @override
  FutureOr<Uri> getUri(TestRequest request) => request.uri;
}

class TestRequest {
  final Uri uri;
  final String method;
  final String body;

  TestRequest(this.uri, this.method, this.body);
}

class TestResponse {
  final int statusCode;
  final String body;
  final Map<String, String> headers;

  Document get document => Document.fromJson(json.decode(body), null);

  TestResponse(this.statusCode, this.body, this.headers);
}

class DummyController implements JsonApiController {
  @override
  FutureOr<JsonApiResponse> addToRelationship(request, String type, String id,
      String relationship, Iterable<Identifier> identifiers) {
    // TODO: implement addToRelationship
    return null;
  }

  @override
  FutureOr<JsonApiResponse> createResource(
      request, String type, Resource resource) {
    // TODO: implement createResource
    return null;
  }

  @override
  FutureOr<JsonApiResponse> deleteFromRelationship(request, String type,
      String id, String relationship, Iterable<Identifier> identifiers) {
    // TODO: implement deleteFromRelationship
    return null;
  }

  @override
  FutureOr<JsonApiResponse> deleteResource(request, String type, String id) {
    // TODO: implement deleteResource
    return null;
  }

  @override
  FutureOr<JsonApiResponse> fetchCollection(request, String type) {
    // TODO: implement fetchCollection
    return null;
  }

  @override
  FutureOr<JsonApiResponse> fetchRelated(
      request, String type, String id, String relationship) {
    // TODO: implement fetchRelated
    return null;
  }

  @override
  FutureOr<JsonApiResponse> fetchRelationship(
      request, String type, String id, String relationship) {
    // TODO: implement fetchRelationship
    return null;
  }

  @override
  FutureOr<JsonApiResponse> fetchResource(request, String type, String id) {
    // TODO: implement fetchResource
    return null;
  }

  @override
  FutureOr<JsonApiResponse> replaceToMany(request, String type, String id,
      String relationship, Iterable<Identifier> identifiers) {
    // TODO: implement replaceToMany
    return null;
  }

  @override
  FutureOr<JsonApiResponse> replaceToOne(request, String type, String id,
      String relationship, Identifier identifier) {
    // TODO: implement replaceToOne
    return null;
  }

  @override
  FutureOr<JsonApiResponse> updateResource(
      request, String type, String id, Resource resource) {
    // TODO: implement updateResource
    return null;
  }
}
