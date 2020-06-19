import 'dart:convert';

import 'package:json_api/json_api.dart';
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
    test('Sends correct request when given minimum arguments', () async {
      http.response = mock.collection;
      final response = await client.fetchCollection('articles');
      expect(response.length, 1);
      expect(http.request.method, 'get');
      expect(http.request.uri.toString(), '/articles');
      expect(http.request.headers, {'accept': 'application/vnd.api+json'});
    });

    test('Sends correct request when given all possible arguments', () async {
      http.response = mock.collection;
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
      expect(http.request.method, 'get');
      expect(http.request.uri.toString(),
          r'/articles?include=author&fields%5Bauthor%5D=name&sort=title%2C-date&page%5Blimit%5D=10&foo=bar');
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
    test('Sends correct request when given minimum arguments', () async {
      http.response = mock.collection;
      final response =
          await client.fetchRelatedCollection('people', '1', 'articles');
      expect(response.length, 1);
      expect(http.request.method, 'get');
      expect(http.request.uri.toString(), '/people/1/articles');
      expect(http.request.headers, {'accept': 'application/vnd.api+json'});
    });

    test('Sends correct request when given all possible arguments', () async {
      http.response = mock.collection;
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
      expect(http.request.method, 'get');
      expect(http.request.uri.toString(),
          r'/people/1/articles?include=author&fields%5Bauthor%5D=name&sort=title%2C-date&page%5Blimit%5D=10&foo=bar');
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
    test('Sends correct request when given minimum arguments', () async {
      http.response = mock.primaryResource;
      final response = await client.fetchResource('articles', '1');
      expect(response.resource.type, 'articles');
      expect(http.request.method, 'get');
      expect(http.request.uri.toString(), '/articles/1');
      expect(http.request.headers, {'accept': 'application/vnd.api+json'});
    });

    test('Sends correct request when given all possible arguments', () async {
      http.response = mock.primaryResource;
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
      expect(http.request.method, 'get');
      expect(http.request.uri.toString(),
          r'/articles/1?include=author&fields%5Bauthor%5D=name&foo=bar');
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
    test('Sends correct request when given minimum arguments', () async {
      http.response = mock.relatedResourceNull;
      final response =
          await client.fetchRelatedResource('articles', '1', 'author');
      expect(response.resource, isA<Nothing<Resource>>());
      expect(http.request.method, 'get');
      expect(http.request.uri.toString(), '/articles/1/author');
      expect(http.request.headers, {'accept': 'application/vnd.api+json'});
    });

    test('Sends correct request when given all possible arguments', () async {
      http.response = mock.relatedResourceNull;
      final response = await client
          .fetchRelatedResource('articles', '1', 'author', headers: {
        'foo': 'bar'
      }, include: [
        'author'
      ], fields: {
        'author': ['name']
      }, query: {
        'foo': 'bar'
      });
      expect(response.resource, isA<Nothing<Resource>>());
      expect(http.request.method, 'get');
      expect(http.request.uri.toString(),
          r'/articles/1/author?include=author&fields%5Bauthor%5D=name&foo=bar');
      expect(http.request.headers,
          {'accept': 'application/vnd.api+json', 'foo': 'bar'});
    });

    test('Throws RequestFailure', () async {
      http.response = mock.error422;
      try {
        await client.fetchRelatedResource('articles', '1', 'author');
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 422);
        expect(e.errors.first.status, '422');
      }
    });
  });

  group('Fetch Relationship', () {
    test('Sends correct request when given minimum arguments', () async {
      http.response = mock.one;
      final response =
          await client.fetchRelationship<One>('articles', '1', 'author');
      expect(response.relationship, isA<One>());
      expect(http.request.method, 'get');
      expect(http.request.uri.toString(), '/articles/1/relationships/author');
      expect(http.request.headers, {'accept': 'application/vnd.api+json'});
    });

    test('Sends correct request when given all possible arguments', () async {
      http.response = mock.one;
      final response = await client.fetchRelationship<One>(
          'articles', '1', 'author',
          headers: {'foo': 'bar'}, query: {'foo': 'bar'});
      expect(response.relationship, isA<One>());
      expect(http.request.method, 'get');
      expect(http.request.uri.toString(),
          '/articles/1/relationships/author?foo=bar');
      expect(http.request.headers,
          {'accept': 'application/vnd.api+json', 'foo': 'bar'});
    });

    test('Throws RequestFailure', () async {
      http.response = mock.error422;
      try {
        await client.fetchRelationship<One>('articles', '1', 'author');
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 422);
        expect(e.errors.first.status, '422');
      }
    });
  });

  group('Create New Resource', () {
    test('Sends correct request when given minimum arguments', () async {
      http.response = mock.primaryResource;
      final response = await client.createNewResource('articles');
      expect(response.resource.type, 'articles');
      expect(http.request.method, 'post');
      expect(http.request.uri.toString(), '/articles');
      expect(http.request.headers, {
        'accept': 'application/vnd.api+json',
        'content-type': 'application/vnd.api+json'
      });
      expect(jsonDecode(http.request.body), {
        'data': {'type': 'articles'}
      });
    });

    test('Sends correct request when given all possible arguments', () async {
      http.response = mock.primaryResource;
      final response = await client.createNewResource('articles', attributes: {
        'cool': true
      }, one: {
        'author': 'people:42'
      }, many: {
        'tags': ['tags:1', 'tags:2']
      }, headers: {
        'foo': 'bar'
      });
      expect(response.resource.type, 'articles');
      expect(http.request.method, 'post');
      expect(http.request.uri.toString(), '/articles');
      expect(http.request.headers, {
        'accept': 'application/vnd.api+json',
        'content-type': 'application/vnd.api+json',
        'foo': 'bar'
      });
      expect(jsonDecode(http.request.body), {
        'data': {
          'type': 'articles',
          'attributes': {'cool': true},
          'relationships': {
            'author': {
              'data': {'type': 'people', 'id': '42'}
            },
            'tags': {
              'data': [
                {'type': 'tags', 'id': '1'},
                {'type': 'tags', 'id': '2'}
              ]
            }
          }
        }
      });
    });

    test('Throws RequestFailure', () async {
      http.response = mock.error422;
      try {
        await client.createNewResource('articles');
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 422);
        expect(e.errors.first.status, '422');
      }
    });
  });

  group('Create Resource', () {
    test('Sends correct request when given minimum arguments', () async {
      http.response = mock.primaryResource;
      final response = await client.createResource('articles', '1');
      expect(response.resource, isA<Just<Resource>>());
      expect(http.request.method, 'post');
      expect(http.request.uri.toString(), '/articles');
      expect(http.request.headers, {
        'accept': 'application/vnd.api+json',
        'content-type': 'application/vnd.api+json'
      });
      expect(jsonDecode(http.request.body), {
        'data': {'type': 'articles', 'id': '1'}
      });
    });

    test('Sends correct request when given all possible arguments', () async {
      http.response = mock.primaryResource;
      final response =
          await client.createResource('articles', '1', attributes: {
        'cool': true
      }, one: {
        'author': 'people:42'
      }, many: {
        'tags': ['tags:1', 'tags:2']
      }, headers: {
        'foo': 'bar'
      });
      expect(response.resource, isA<Just<Resource>>());
      expect(http.request.method, 'post');
      expect(http.request.uri.toString(), '/articles');
      expect(http.request.headers, {
        'accept': 'application/vnd.api+json',
        'content-type': 'application/vnd.api+json',
        'foo': 'bar'
      });
      expect(jsonDecode(http.request.body), {
        'data': {
          'type': 'articles',
          'id': '1',
          'attributes': {'cool': true},
          'relationships': {
            'author': {
              'data': {'type': 'people', 'id': '42'}
            },
            'tags': {
              'data': [
                {'type': 'tags', 'id': '1'},
                {'type': 'tags', 'id': '2'}
              ]
            }
          }
        }
      });
    });

    test('Throws RequestFailure', () async {
      http.response = mock.error422;
      try {
        await client.createResource('articles', '1');
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 422);
        expect(e.errors.first.status, '422');
      }
    });
  });

  group('Create Resource', () {
    test('Sends correct request when given minimum arguments', () async {
      http.response = HttpResponse(204);
      final response = await client.deleteResource('articles', '1');
      expect(response.meta, isEmpty);
      expect(http.request.method, 'delete');
      expect(http.request.uri.toString(), '/articles/1');
      expect(http.request.headers, {
        'accept': 'application/vnd.api+json',
      });
      expect(http.request.body, isEmpty);
    });

    test('Sends correct request when given all possible arguments', () async {
      http.response = HttpResponse(204);
      final response =
          await client.deleteResource('articles', '1', headers: {'foo': 'bar'});
      expect(response.meta, isEmpty);
      expect(http.request.method, 'delete');
      expect(http.request.uri.toString(), '/articles/1');
      expect(http.request.headers, {
        'accept': 'application/vnd.api+json',
        'foo': 'bar',
      });
      expect(http.request.body, isEmpty);
    });

    test('Throws RequestFailure', () async {
      http.response = mock.error422;
      try {
        await client.deleteResource('articles', '1');
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 422);
        expect(e.errors.first.status, '422');
      }
    });
  });

  group('Update Resource', () {
    test('Sends correct request when given minimum arguments', () async {
      http.response = mock.primaryResource;
      final response = await client.updateResource('articles', '1');
      expect(response.resource, isA<Just<Resource>>());
      expect(http.request.method, 'patch');
      expect(http.request.uri.toString(), '/articles/1');
      expect(http.request.headers, {
        'accept': 'application/vnd.api+json',
        'content-type': 'application/vnd.api+json'
      });
      expect(jsonDecode(http.request.body), {
        'data': {'type': 'articles', 'id': '1'}
      });
    });

    test('Sends correct request when given all possible arguments', () async {
      http.response = mock.primaryResource;
      final response =
          await client.updateResource('articles', '1', attributes: {
        'cool': true
      }, one: {
        'author': 'people:42'
      }, many: {
        'tags': ['tags:1', 'tags:2']
      }, headers: {
        'foo': 'bar'
      });
      expect(response.resource, isA<Just<Resource>>());
      expect(http.request.method, 'patch');
      expect(http.request.uri.toString(), '/articles/1');
      expect(http.request.headers, {
        'accept': 'application/vnd.api+json',
        'content-type': 'application/vnd.api+json',
        'foo': 'bar'
      });
      expect(jsonDecode(http.request.body), {
        'data': {
          'type': 'articles',
          'id': '1',
          'attributes': {'cool': true},
          'relationships': {
            'author': {
              'data': {'type': 'people', 'id': '42'}
            },
            'tags': {
              'data': [
                {'type': 'tags', 'id': '1'},
                {'type': 'tags', 'id': '2'}
              ]
            }
          }
        }
      });
    });

    test('Throws RequestFailure', () async {
      http.response = mock.error422;
      try {
        await client.updateResource('articles', '1');
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 422);
        expect(e.errors.first.status, '422');
      }
    });
  });

  group('Replace One', () {
    test('Sends correct request when given minimum arguments', () async {
      http.response = mock.one;
      final response =
          await client.replaceOne('articles', '1', 'author', 'people:42');
      expect(response.relationship, isA<Just<One>>());
      expect(http.request.method, 'patch');
      expect(http.request.uri.toString(), '/articles/1/relationships/author');
      expect(http.request.headers, {
        'accept': 'application/vnd.api+json',
        'content-type': 'application/vnd.api+json'
      });
      expect(jsonDecode(http.request.body), {
        'data': {'type': 'people', 'id': '42'}
      });
    });

    test('Sends correct request when given all possible arguments', () async {
      http.response = mock.one;
      final response = await client.replaceOne(
          'articles', '1', 'author', 'people:42',
          headers: {'foo': 'bar'});
      expect(response.relationship, isA<Just<One>>());
      expect(http.request.method, 'patch');
      expect(http.request.uri.toString(), '/articles/1/relationships/author');
      expect(http.request.headers, {
        'accept': 'application/vnd.api+json',
        'content-type': 'application/vnd.api+json',
        'foo': 'bar'
      });
      expect(jsonDecode(http.request.body), {
        'data': {'type': 'people', 'id': '42'}
      });
    });

    test('Throws RequestFailure', () async {
      http.response = mock.error422;
      try {
        await client.replaceOne('articles', '1', 'author', 'people:42');
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 422);
        expect(e.errors.first.status, '422');
      }
    });
  });

  group('Delete One', () {
    test('Sends correct request when given minimum arguments', () async {
      http.response = mock.one;
      final response = await client.deleteOne('articles', '1', 'author');
      expect(response.relationship, isA<Just<One>>());
      expect(http.request.method, 'patch');
      expect(http.request.uri.toString(), '/articles/1/relationships/author');
      expect(http.request.headers, {
        'accept': 'application/vnd.api+json',
        'content-type': 'application/vnd.api+json'
      });
      expect(jsonDecode(http.request.body), {'data': null});
    });

    test('Sends correct request when given all possible arguments', () async {
      http.response = mock.one;
      final response = await client
          .deleteOne('articles', '1', 'author', headers: {'foo': 'bar'});
      expect(response.relationship, isA<Just<One>>());
      expect(http.request.method, 'patch');
      expect(http.request.uri.toString(), '/articles/1/relationships/author');
      expect(http.request.headers, {
        'accept': 'application/vnd.api+json',
        'content-type': 'application/vnd.api+json',
        'foo': 'bar'
      });
      expect(jsonDecode(http.request.body), {'data': null});
    });

    test('Throws RequestFailure', () async {
      http.response = mock.error422;
      try {
        await client.deleteOne('articles', '1', 'author');
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 422);
        expect(e.errors.first.status, '422');
      }
    });
  });

  group('Delete Many', () {
    test('Sends correct request when given minimum arguments', () async {
      http.response = mock.many;
      final response =
          await client.deleteMany('articles', '1', 'tags', ['tags:1']);
      expect(response.relationship, isA<Just<Many>>());
      expect(http.request.method, 'delete');
      expect(http.request.uri.toString(), '/articles/1/relationships/tags');
      expect(http.request.headers, {
        'accept': 'application/vnd.api+json',
        'content-type': 'application/vnd.api+json'
      });
      expect(jsonDecode(http.request.body), {
        'data': [
          {'type': 'tags', 'id': '1'}
        ]
      });
    });

    test('Sends correct request when given all possible arguments', () async {
      http.response = mock.many;
      final response = await client.deleteMany(
          'articles', '1', 'tags', ['tags:1'],
          headers: {'foo': 'bar'});
      expect(response.relationship, isA<Just<Many>>());
      expect(http.request.method, 'delete');
      expect(http.request.uri.toString(), '/articles/1/relationships/tags');
      expect(http.request.headers, {
        'accept': 'application/vnd.api+json',
        'content-type': 'application/vnd.api+json',
        'foo': 'bar'
      });
      expect(jsonDecode(http.request.body), {
        'data': [
          {'type': 'tags', 'id': '1'}
        ]
      });
    });

    test('Throws RequestFailure', () async {
      http.response = mock.error422;
      try {
        await client.deleteMany('articles', '1', 'tags', ['tags:1']);
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 422);
        expect(e.errors.first.status, '422');
      }
    });
  });

  group('Replace Many', () {
    test('Sends correct request when given minimum arguments', () async {
      http.response = mock.many;
      final response =
          await client.replaceMany('articles', '1', 'tags', ['tags:1']);
      expect(response.relationship, isA<Just<Many>>());
      expect(http.request.method, 'patch');
      expect(http.request.uri.toString(), '/articles/1/relationships/tags');
      expect(http.request.headers, {
        'accept': 'application/vnd.api+json',
        'content-type': 'application/vnd.api+json'
      });
      expect(jsonDecode(http.request.body), {
        'data': [
          {'type': 'tags', 'id': '1'}
        ]
      });
    });

    test('Sends correct request when given all possible arguments', () async {
      http.response = mock.many;
      final response = await client.replaceMany(
          'articles', '1', 'tags', ['tags:1'],
          headers: {'foo': 'bar'});
      expect(response.relationship, isA<Just<Many>>());
      expect(http.request.method, 'patch');
      expect(http.request.uri.toString(), '/articles/1/relationships/tags');
      expect(http.request.headers, {
        'accept': 'application/vnd.api+json',
        'content-type': 'application/vnd.api+json',
        'foo': 'bar'
      });
      expect(jsonDecode(http.request.body), {
        'data': [
          {'type': 'tags', 'id': '1'}
        ]
      });
    });

    test('Throws RequestFailure', () async {
      http.response = mock.error422;
      try {
        await client.replaceMany('articles', '1', 'tags', ['tags:1']);
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 422);
        expect(e.errors.first.status, '422');
      }
    });
  });

  group('Add Many', () {
    test('Sends correct request when given minimum arguments', () async {
      http.response = mock.many;
      final response =
          await client.addMany('articles', '1', 'tags', ['tags:1']);
      expect(response.relationship, isA<Just<Many>>());
      expect(http.request.method, 'post');
      expect(http.request.uri.toString(), '/articles/1/relationships/tags');
      expect(http.request.headers, {
        'accept': 'application/vnd.api+json',
        'content-type': 'application/vnd.api+json'
      });
      expect(jsonDecode(http.request.body), {
        'data': [
          {'type': 'tags', 'id': '1'}
        ]
      });
    });

    test('Sends correct request when given all possible arguments', () async {
      http.response = mock.many;
      final response = await client.addMany('articles', '1', 'tags', ['tags:1'],
          headers: {'foo': 'bar'});
      expect(response.relationship, isA<Just<Many>>());
      expect(http.request.method, 'post');
      expect(http.request.uri.toString(), '/articles/1/relationships/tags');
      expect(http.request.headers, {
        'accept': 'application/vnd.api+json',
        'content-type': 'application/vnd.api+json',
        'foo': 'bar'
      });
      expect(jsonDecode(http.request.body), {
        'data': [
          {'type': 'tags', 'id': '1'}
        ]
      });
    });

    test('Throws RequestFailure', () async {
      http.response = mock.error422;
      try {
        await client.addMany('articles', '1', 'tags', ['tags:1']);
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 422);
        expect(e.errors.first.status, '422');
      }
    });
  });

  group('Call', () {
    test('Sends correct request when given minimum arguments', () async {
      http.response = HttpResponse(204);
      final response =
          await client.call(JsonApiRequest('get'), Uri.parse('/foo'));
      expect(response, http.response);
      expect(http.request.method, 'get');
      expect(http.request.uri.toString(), '/foo');
      expect(http.request.headers, {
        'accept': 'application/vnd.api+json',
      });
      expect(http.request.body, isEmpty);
    });

    test('Sends correct request when given all possible arguments', () async {
      http.response = HttpResponse(204);
      final response = await client.call(
          JsonApiRequest('get', document: {
            'data': null
          }, headers: {
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
          }),
          Uri.parse('/foo'));
      expect(response, http.response);
      expect(http.request.method, 'get');
      expect(http.request.uri.toString(),
          r'/foo?include=author&fields%5Bauthor%5D=name&sort=title%2C-date&page%5Blimit%5D=10&foo=bar');
      expect(http.request.headers, {
        'accept': 'application/vnd.api+json',
        'content-type': 'application/vnd.api+json',
        'foo': 'bar'
      });
      expect(jsonDecode(http.request.body), {'data': null});
    });

    test('Throws RequestFailure', () async {
      http.response = mock.error422;
      try {
        await client.call(JsonApiRequest('get'), Uri.parse('/foo'));
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
