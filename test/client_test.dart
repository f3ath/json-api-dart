import 'package:json_api/json_api.dart';
import 'package:json_api_common/http.dart';
import 'package:json_api_common/url_design.dart';
import 'package:maybe_just_nothing/maybe_just_nothing.dart';
import 'package:test/test.dart';

import 'responses.dart' as mock;

void main() {
  final http = MockHandler();
  final client = JsonApiClient(http, UrlDesign());
  setUp(() {
    http.request = null;
    http.response = null;
  });

  group('Fetch Collection', () {
    test('Sends correct request when given no arguments', () async {
      http.response = mock.fetchCollection200;
      final response = await client.fetchCollection('articles');
      expect(response.length, 1);
      expect(http.request.method, 'GET');
      expect(http.request.uri.toString(), '/articles');
      expect(http.request.headers, {'accept': 'application/vnd.api+json'});
    });

    test('Sends correct request when given all possible arguments', () async {
      http.response = mock.fetchCollection200;
      final response = await client.fetchCollection('articles', headers: {
        'foo': 'bar'
      }, include: [
        'author'
      ], fields: {
        'author': ['name']
      }, sort: [
        'title',
        '-date'
      ], page: {
        'limit': '10'
      }, query: {
        'foo': 'bar'
      });
      expect(response.length, 1);
      expect(http.request.method, 'GET');
      expect(http.request.uri.toString(),
          '/articles?include=author&fields%5Bauthor%5D=name&sort=title%2C-date&page%5Blimit%5D=10&foo=bar');
      expect(http.request.headers,
          {'accept': 'application/vnd.api+json', 'foo': 'bar'});
    });

    test('Throws RequestFailure', () async {
      http.response = mock.error422;
      try {
        await client.fetchCollection('articles');
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 422);
        expect(e.errors.first.status, '422');
      }
    });
  });

  group('Fetch Related Collection', () {
    test('Sends correct request when given no arguments', () async {
      http.response = mock.fetchCollection200;
      final response =
          await client.fetchRelatedCollection('people', '1', 'articles');
      expect(response.length, 1);
      expect(http.request.method, 'GET');
      expect(http.request.uri.toString(), '/people/1/articles');
      expect(http.request.headers, {'accept': 'application/vnd.api+json'});
    });

    test('Sends correct request when given all possible arguments', () async {
      http.response = mock.fetchCollection200;
      final response = await client
          .fetchRelatedCollection('people', '1', 'articles', headers: {
        'foo': 'bar'
      }, include: [
        'author'
      ], fields: {
        'author': ['name']
      }, sort: [
        'title',
        '-date'
      ], page: {
        'limit': '10'
      }, query: {
        'foo': 'bar'
      });
      expect(response.length, 1);
      expect(http.request.method, 'GET');
      expect(http.request.uri.toString(),
          '/people/1/articles?include=author&fields%5Bauthor%5D=name&sort=title%2C-date&page%5Blimit%5D=10&foo=bar');
      expect(http.request.headers,
          {'accept': 'application/vnd.api+json', 'foo': 'bar'});
    });

    test('Throws RequestFailure', () async {
      http.response = mock.error422;
      try {
        await client.fetchRelatedCollection('people', '1', 'articles');
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 422);
        expect(e.errors.first.status, '422');
      }
    });
  });

  group('Fetch Primary Resource', () {
    test('Sends correct request when given no arguments', () async {
      http.response = mock.fetchResource200;
      final response = await client.fetchResource('articles', '1');
      expect(response.resource.type, 'articles');
      expect(http.request.method, 'GET');
      expect(http.request.uri.toString(), '/articles/1');
      expect(http.request.headers, {'accept': 'application/vnd.api+json'});
    });

    test('Sends correct request when given all possible arguments', () async {
      http.response = mock.fetchResource200;
      final response = await client.fetchResource('articles', '1', headers: {
        'foo': 'bar'
      }, include: [
        'author'
      ], fields: {
        'author': ['name']
      }, query: {
        'foo': 'bar'
      });
      expect(response.resource.type, 'articles');
      expect(http.request.method, 'GET');
      expect(http.request.uri.toString(),
          '/articles/1?include=author&fields%5Bauthor%5D=name&foo=bar');
      expect(http.request.headers,
          {'accept': 'application/vnd.api+json', 'foo': 'bar'});
    });

    test('Throws RequestFailure', () async {
      http.response = mock.error422;
      try {
        await client.fetchResource('articles', '1');
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 422);
        expect(e.errors.first.status, '422');
      }
    });
  });

  group('Fetch Related Resource', () {
    test('Sends correct request when given no arguments', () async {
      http.response = mock.fetchRelatedResourceNull200;
      final response =
          await client.fetchRelatedResource('articles', '1', 'author');
      expect(response.resource, isA<Nothing<ResourceWithIdentity>>());
      expect(http.request.method, 'GET');
      expect(http.request.uri.toString(), '/articles/1');
      expect(http.request.headers, {'accept': 'application/vnd.api+json'});
    });

    test('Sends correct request when given all possible arguments', () async {
      http.response = mock.fetchResource200;
      final response = await client.fetchResource('articles', '1', headers: {
        'foo': 'bar'
      }, include: [
        'author'
      ], fields: {
        'author': ['name']
      }, query: {
        'foo': 'bar'
      });
      expect(response.resource.type, 'articles');
      expect(http.request.method, 'GET');
      expect(http.request.uri.toString(),
          '/articles/1?include=author&fields%5Bauthor%5D=name&foo=bar');
      expect(http.request.headers,
          {'accept': 'application/vnd.api+json', 'foo': 'bar'});
    });

    test('Throws RequestFailure', () async {
      http.response = mock.error422;
      try {
        await client.fetchResource('articles', '1');
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 422);
        expect(e.errors.first.status, '422');
      }
    });
  });
}

class MockHandler implements HttpHandler {
  HttpResponse response;
  HttpRequest request;

  @override
  Future<HttpResponse> call(HttpRequest request) async {
    this.request = request;
    return response;
  }
}
