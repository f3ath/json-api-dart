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
          uriDesign.relationshipUri('books', '1', 'author'), 'patch', '{}');
      final rs = await handler.call(rq);
      expect(rs.statusCode, 400);
      final error = Document.fromJson(json.decode(rs.body), null).errors.first;
      expect(error.status, '400');
      expect(error.title, 'Bad request');
      expect(error.detail, 'Incomplete relationship object');
    });

    test('returns `bad request` when payload is not a valid JSON', () async {
      final rq =
          TestRequest(uriDesign.collectionUri('books'), 'post', '"ololo"abc');
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
          TestRequest(uriDesign.collectionUri('books'), 'post', '"oops"');
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
          TestRequest(uriDesign.collectionUri('books'), 'post', '{"data": {}}');
      final rs = await handler.call(rq);
      expect(rs.statusCode, 400);
      final error = Document.fromJson(json.decode(rs.body), null).errors.first;
      expect(error.status, '400');
      expect(error.title, 'Bad request');
      expect(error.detail, "Resource 'type' must not be null");
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

class DummyController extends JsonApiControllerBase {}
