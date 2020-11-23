import 'dart:convert';

import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/test/mock_handler.dart';
import 'package:json_api/src/test/response.dart' as mock;
import 'package:test/test.dart';

void main() {
  final http = MockHandler();
  final client =
      JsonApiClient(RecommendedUrlDesign(Uri(path: '/')), httpHandler: http);

  group('Failure', () {
    test('RequestFailure', () async {
      http.response = mock.error422;
      try {
        await client.fetchCollection('articles');
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 422);
        expect(e.document.errors.first.status, '422');
        expect(e.document.errors.first.title, 'Invalid Attribute');
      }
    });
    test('ServerError', () async {
      http.response = mock.error500;
      try {
        await client.fetchCollection('articles');
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 500);
      }
    });
  });

  group('Fetch Collection', () {
    test('Min', () async {
      http.response = mock.collectionMin;
      final response = await client.fetchCollection('articles');
      expect(response.collection.single.key, 'articles:1');
      expect(response.included, isEmpty);
      expect(http.request.method, 'get');
      expect(http.request.uri.toString(), '/articles');
      expect(http.request.headers, {'accept': 'application/vnd.api+json'});
    });
  });

  test('Full', () async {
    http.response = mock.collectionFull;
    final response = await client.fetchCollection('articles', headers: {
      'foo': 'bar'
    }, query: {
      'foo': 'bar'
    }, include: [
      'author'
    ], fields: {
      'author': ['name']
    }, page: {
      'limit': '10'
    }, sort: [
      'title',
      '-date'
    ]);

    expect(response.collection.length, 1);
    expect(response.included.length, 3);
    expect(http.request.method, 'get');
    expect(http.request.uri.path, '/articles');
    expect(http.request.uri.queryParameters, {
      'include': 'author',
      'fields[author]': 'name',
      'sort': 'title,-date',
      'page[limit]': '10',
      'foo': 'bar'
    });
    expect(http.request.headers,
        {'accept': 'application/vnd.api+json', 'foo': 'bar'});
  });

  group('Fetch Related Collection', () {
    test('Min', () async {
      http.response = mock.collectionFull;
      final response =
          await client.fetchRelatedCollection('people', '1', 'articles');
      expect(response.collection.length, 1);
      expect(http.request.method, 'get');
      expect(http.request.uri.path, '/people/1/articles');
      expect(http.request.headers, {'accept': 'application/vnd.api+json'});
    });

    test('Full', () async {
      http.response = mock.collectionFull;
      final response = await client
          .fetchRelatedCollection('people', '1', 'articles', headers: {
        'foo': 'bar'
      }, query: {
        'foo': 'bar'
      }, include: [
        'author'
      ], fields: {
        'author': ['name']
      }, page: {
        'limit': '10'
      }, sort: [
        'title',
        '-date'
      ]);

      expect(response.collection.length, 1);
      expect(response.included.length, 3);
      expect(http.request.method, 'get');
      expect(http.request.uri.path, '/people/1/articles');
      expect(http.request.uri.queryParameters, {
        'include': 'author',
        'fields[author]': 'name',
        'sort': 'title,-date',
        'page[limit]': '10',
        'foo': 'bar'
      });
      expect(http.request.headers,
          {'accept': 'application/vnd.api+json', 'foo': 'bar'});
    });
  });

  group('Fetch Primary Resource', () {
    test('Min', () async {
      http.response = mock.primaryResource;
      final response = await client.fetchResource('articles', '1');
      expect(response.resource.type, 'articles');
      expect(http.request.method, 'get');
      expect(http.request.uri.toString(), '/articles/1');
      expect(http.request.headers, {'accept': 'application/vnd.api+json'});
    });

    test('Full', () async {
      http.response = mock.primaryResource;
      final response = await client.fetchResource('articles', '1', headers: {
        'foo': 'bar'
      }, query: {
        'foo': 'bar'
      }, include: [
        'author'
      ], fields: {
        'author': ['name']
      });
      expect(response.resource.type, 'articles');
      expect(response.included.length, 3);
      expect(http.request.method, 'get');
      expect(http.request.uri.path, '/articles/1');
      expect(http.request.uri.queryParameters,
          {'include': 'author', 'fields[author]': 'name', 'foo': 'bar'});
      expect(http.request.headers,
          {'accept': 'application/vnd.api+json', 'foo': 'bar'});
    });
  });

  group('Fetch Related Resource', () {
    test('Min', () async {
      http.response = mock.primaryResource;
      final response =
          await client.fetchRelatedResource('articles', '1', 'author');
      expect(response.resource?.type, 'articles');
      expect(response.included.length, 3);
      expect(http.request.method, 'get');
      expect(http.request.uri.toString(), '/articles/1/author');
      expect(http.request.headers, {'accept': 'application/vnd.api+json'});
    });

    test('Full', () async {
      http.response = mock.primaryResource;
      final response = await client
          .fetchRelatedResource('articles', '1', 'author', headers: {
        'foo': 'bar'
      }, query: {
        'foo': 'bar'
      }, include: [
        'author'
      ], fields: {
        'author': ['name']
      });
      expect(response.resource?.type, 'articles');
      expect(response.included.length, 3);
      expect(http.request.method, 'get');
      expect(http.request.uri.path, '/articles/1/author');
      expect(http.request.uri.queryParameters,
          {'include': 'author', 'fields[author]': 'name', 'foo': 'bar'});
      expect(http.request.headers,
          {'accept': 'application/vnd.api+json', 'foo': 'bar'});
    });

    test('Missing resource', () async {
      http.response = mock.relatedResourceNull;
      final response =
      await client.fetchRelatedResource('articles', '1', 'author');
      expect(response.resource, isNull);
      expect(response.included, isEmpty);
      expect(http.request.method, 'get');
      expect(http.request.uri.toString(), '/articles/1/author');
      expect(http.request.headers, {'accept': 'application/vnd.api+json'});
    });
  });

  group('Fetch Relationship', () {
    test('Min', () async {
      http.response = mock.one;
      final response = await client.fetchOne('articles', '1', 'author');
      expect(response.included.length, 3);
      expect(http.request.method, 'get');
      expect(http.request.uri.toString(), '/articles/1/relationships/author');
      expect(http.request.headers, {'accept': 'application/vnd.api+json'});
    });

    test('Full', () async {
      http.response = mock.one;
      final response = await client.fetchOne('articles', '1', 'author',
          headers: {'foo': 'bar'}, query: {'foo': 'bar'});
      expect(response.included.length, 3);
      expect(http.request.method, 'get');
      expect(http.request.uri.path, '/articles/1/relationships/author');
      expect(http.request.uri.queryParameters, {'foo': 'bar'});
      expect(http.request.headers,
          {'accept': 'application/vnd.api+json', 'foo': 'bar'});
    });
  });

  group('Create New Resource', () {
    test('Min', () async {
      http.response = mock.primaryResource;
      final response = await client.createNew('articles');
      expect(response.resource.type, 'articles');
      expect(
          response.links['self'].toString(), 'http://example.com/articles/1');
      expect(response.included.length, 3);
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

    test('Full', () async {
      http.response = mock.primaryResource;
      final response = await client.createNew('articles', attributes: {
        'cool': true
      }, one: {
        'author': Identifier('people', '42')..meta.addAll({'hey': 'yos'})
      }, many: {
        'tags': [Identifier('tags', '1'), Identifier('tags', '2')]
      }, meta: {
        'answer': 42
      }, headers: {
        'foo': 'bar'
      });
      expect(response.resource.type, 'articles');
      expect(
          response.links['self'].toString(), 'http://example.com/articles/1');
      expect(response.included.length, 3);
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
              'data': {
                'type': 'people',
                'id': '42',
                'meta': {'hey': 'yos'}
              }
            },
            'tags': {
              'data': [
                {'type': 'tags', 'id': '1'},
                {'type': 'tags', 'id': '2'}
              ]
            }
          },
          'meta': {'answer': 42}
        }
      });
    });
  });

  group('Create Resource', () {
    test('Min', () async {
      http.response = mock.primaryResource;
      final response = await client.create('articles', '1');
      expect(response.resource.type, 'articles');
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

    test('Min with 204 No Content', () async {
      http.response = mock.noContent;
      final response = await client.create('articles', '1');
      expect(response.resource, isNull);
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

    test('Full', () async {
      http.response = mock.primaryResource;
      final response = await client.create('articles', '1', attributes: {
        'cool': true
      }, one: {
        'author': Identifier('people', '42')..meta.addAll({'hey': 'yos'})
      }, many: {
        'tags': [Identifier('tags', '1'), Identifier('tags', '2')]
      }, meta: {
        'answer': 42
      }, headers: {
        'foo': 'bar'
      });
      expect(response.resource?.type, 'articles');
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
              'data': {
                'type': 'people',
                'id': '42',
                'meta': {'hey': 'yos'}
              }
            },
            'tags': {
              'data': [
                {'type': 'tags', 'id': '1'},
                {'type': 'tags', 'id': '2'}
              ]
            }
          },
          'meta': {'answer': 42}
        }
      });
    });
  });

  group('Update Resource', () {
    test('Min', () async {
      http.response = mock.primaryResource;
      final response = await client.updateResource('articles', '1');
      expect(response.resource?.type, 'articles');
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

    test('Min with 204 No Content', () async {
      http.response = mock.noContent;
      final response = await client.updateResource('articles', '1');
      expect(response.resource, isNull);
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

    test('Full', () async {
      http.response = mock.primaryResource;
      final response =
          await client.updateResource('articles', '1', attributes: {
        'cool': true
      }, one: {
        'author': Identifier('people', '42')..meta.addAll({'hey': 'yos'})
      }, many: {
        'tags': [Identifier('tags', '1'), Identifier('tags', '2')]
      }, meta: {
        'answer': 42
      }, headers: {
        'foo': 'bar'
      });
      expect(response.resource?.type, 'articles');
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
              'data': {
                'type': 'people',
                'id': '42',
                'meta': {'hey': 'yos'}
              }
            },
            'tags': {
              'data': [
                {'type': 'tags', 'id': '1'},
                {'type': 'tags', 'id': '2'}
              ]
            }
          },
          'meta': {'answer': 42}
        }
      });
    });
  });

  group('Replace One', () {
    test('Min', () async {
      http.response = mock.one;
      final response = await client.replaceOne(
          'articles', '1', 'author', Identifier('people', '42'));
      expect(response.relationship, isA<One>());
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

    test('Full', () async {
      http.response = mock.one;
      final response = await client.replaceOne(
          'articles', '1', 'author', Identifier('people', '42'),
          headers: {'foo': 'bar'});
      expect(response.relationship, isA<One>());
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
        await client.replaceOne(
            'articles', '1', 'author', Identifier('people', '42'));
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 422);
        expect(e.document.errors.first.status, '422');
      }
    });

    test('Throws FormatException', () async {
      http.response = mock.many;
      expect(
          () => client.replaceOne(
              'articles', '1', 'author', Identifier('people', '42')),
          throwsFormatException);
    });
  });

  group('Delete One', () {
    test('Min', () async {
      http.response = mock.oneEmpty;
      final response = await client.deleteOne('articles', '1', 'author');
      expect(response.relationship, isA<One>());
      expect(response.relationship.identifier, isNull);
      expect(http.request.method, 'patch');
      expect(http.request.uri.toString(), '/articles/1/relationships/author');
      expect(http.request.headers, {
        'accept': 'application/vnd.api+json',
        'content-type': 'application/vnd.api+json'
      });
      expect(jsonDecode(http.request.body), {'data': null});
    });

    test('Full', () async {
      http.response = mock.oneEmpty;
      final response = await client
          .deleteOne('articles', '1', 'author', headers: {'foo': 'bar'});
      expect(response.relationship, isA<One>());
      expect(response.relationship.identifier, isNull);
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
        expect(e.document.errors.first.status, '422');
      }
    });

    test('Throws FormatException', () async {
      http.response = mock.many;
      expect(() => client.deleteOne('articles', '1', 'author'),
          throwsFormatException);
    });
  });

  group('Delete Many', () {
    test('Min', () async {
      http.response = mock.many;
      final response = await client
          .deleteMany('articles', '1', 'tags', [Identifier('tags', '1')]);
      expect(response.relationship, isA<Many>());
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

    test('Full', () async {
      http.response = mock.many;
      final response = await client.deleteMany(
          'articles', '1', 'tags', [Identifier('tags', '1')],
          headers: {'foo': 'bar'});
      expect(response.relationship, isA<Many>());
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
        await client
            .deleteMany('articles', '1', 'tags', [Identifier('tags', '1')]);
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 422);
        expect(e.document.errors.first.status, '422');
      }
    });

    test('Throws FormatException', () async {
      http.response = mock.one;
      expect(
          () => client
              .deleteMany('articles', '1', 'tags', [Identifier('tags', '1')]),
          throwsFormatException);
    });
  });

  group('Replace Many', () {
    test('Min', () async {
      http.response = mock.many;
      final response = await client
          .replaceMany('articles', '1', 'tags', [Identifier('tags', '1')]);
      expect(response.relationship, isA<Many>());
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

    test('Full', () async {
      http.response = mock.many;
      final response = await client.replaceMany(
          'articles', '1', 'tags', [Identifier('tags', '1')],
          headers: {'foo': 'bar'});
      expect(response.relationship, isA<Many>());
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
        await client
            .replaceMany('articles', '1', 'tags', [Identifier('tags', '1')]);
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 422);
        expect(e.document.errors.first.status, '422');
      }
    });

    test('Throws FormatException', () async {
      http.response = mock.one;
      expect(
          () => client
              .replaceMany('articles', '1', 'tags', [Identifier('tags', '1')]),
          throwsFormatException);
    });
  });

  group('Add Many', () {
    test('Min', () async {
      http.response = mock.many;
      final response = await client
          .addMany('articles', '1', 'tags', [Identifier('tags', '1')]);
      expect(response.relationship, isA<Many>());
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

    test('Full', () async {
      http.response = mock.many;
      final response = await client.addMany(
          'articles', '1', 'tags', [Identifier('tags', '1')],
          headers: {'foo': 'bar'});
      expect(response.relationship, isA<Many>());
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
        await client
            .addMany('articles', '1', 'tags', [Identifier('tags', '1')]);
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.http.statusCode, 422);
        expect(e.document.errors.first.status, '422');
        expect(e.toString(), 'JSON:API request failed with HTTP status 422');
      }
    });

    test('Throws FormatException', () async {
      http.response = mock.one;
      expect(
          () => client
              .addMany('articles', '1', 'tags', [Identifier('tags', '1')]),
          throwsFormatException);
    });
  });
}
