import 'dart:convert';

import 'package:http_interop/extensions.dart';
import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:json_api/query.dart';
import 'package:json_api/routing.dart';
import 'package:test/test.dart';

import 'mock_handler.dart';
import 'response.dart' as mock;

void main() {
  final mockHandler = MockHandler();
  final client =
      RoutingClient(StandardUriDesign.pathOnly, Client(mockHandler.handle));

  group('Failure', () {
    test('RequestFailure', () async {
      mockHandler.response = mock.error422();
      try {
        await client.fetchCollection('articles');
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.httpResponse.statusCode, 422);
        expect(e.errors.first.status, '422');
        expect(e.errors.first.title, 'Invalid Attribute');
      }
    });
    test('ServerError', () async {
      mockHandler.response = mock.error500();
      try {
        await client.fetchCollection('articles');
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.httpResponse.statusCode, 500);
      }
    });
  });

  group('Fetch Collection', () {
    test('Min', () async {
      mockHandler.response = mock.collectionMin();
      final response = await client.fetchCollection('articles');
      expect(response.collection.single.type, 'articles');
      expect(response.collection.single.id, '1');
      expect(response.included, isEmpty);
      expect(mockHandler.request.method, equals('get'));
      expect(mockHandler.request.uri.toString(), '/articles');
      expect(mockHandler.request.headers, {
        'Accept': ['application/vnd.api+json']
      });
    });
  });

  test('Full', () async {
    mockHandler.response = mock.collectionFull();
    final response = await client.fetchCollection('articles', headers: {
      'foo': ['bar']
    }, query: [
      Query({
        'foo': ['bar']
      }),
      Include(['author']),
      Fields({
        'author': ['name']
      }),
      Page({'limit': '10'}),
      Sort(['title', '-date'])
    ]);

    expect(response.collection.length, 1);
    expect(response.included.length, 3);
    expect(mockHandler.request.method, equals('get'));
    expect(mockHandler.request.uri.path, '/articles');
    expect(mockHandler.request.uri.queryParameters, {
      'include': 'author',
      'fields[author]': 'name',
      'sort': 'title,-date',
      'page[limit]': '10',
      'foo': 'bar'
    });
    expect(mockHandler.request.headers, {
      'Accept': ['application/vnd.api+json'],
      'foo': ['bar']
    });

    expect(response.meta, {'hello': 'world'});
  });

  group('Fetch Related Collection', () {
    test('Min', () async {
      mockHandler.response = mock.collectionFull();
      final response =
          await client.fetchRelatedCollection('people', '1', 'articles');
      expect(response.collection.length, 1);
      expect(mockHandler.request.method, equals('get'));
      expect(mockHandler.request.uri.path, '/people/1/articles');
      expect(mockHandler.request.headers, {
        'Accept': ['application/vnd.api+json']
      });
    });

    test('Full', () async {
      mockHandler.response = mock.collectionFull();
      final response = await client
          .fetchRelatedCollection('people', '1', 'articles', headers: {
        'foo': ['bar']
      }, query: [
        Query({
          'foo': ['bar']
        }),
        Include(['author']),
        Page({'limit': '10'}),
        Fields({
          'author': ['name']
        }),
        Sort(['title', '-date'])
      ]);

      expect(response.collection.length, 1);
      expect(response.included.length, 3);
      expect(mockHandler.request.method, equals('get'));
      expect(mockHandler.request.uri.path, '/people/1/articles');
      expect(mockHandler.request.uri.queryParameters, {
        'include': 'author',
        'fields[author]': 'name',
        'sort': 'title,-date',
        'page[limit]': '10',
        'foo': 'bar'
      });
      expect(mockHandler.request.headers, {
        'Accept': ['application/vnd.api+json'],
        'foo': ['bar']
      });

      expect(response.meta, {'hello': 'world'});
    });
  });

  group('Fetch Primary Resource', () {
    test('Min', () async {
      mockHandler.response = mock.primaryResource();
      final response = await client.fetchResource('articles', '1');
      expect(response.resource.type, 'articles');
      expect(mockHandler.request.method, equals('get'));
      expect(mockHandler.request.uri.toString(), '/articles/1');
      expect(mockHandler.request.headers, {
        'Accept': ['application/vnd.api+json']
      });
    });

    test('Full', () async {
      mockHandler.response = mock.primaryResource();
      final response = await client.fetchResource('articles', '1', headers: {
        'foo': ['bar']
      }, query: [
        Query({
          'foo': ['bar']
        }),
        Include(['author']),
        Fields({
          'author': ['name']
        })
      ]);
      expect(response.resource.type, 'articles');
      expect(response.included.length, 3);
      expect(mockHandler.request.method, equals('get'));
      expect(mockHandler.request.uri.path, '/articles/1');
      expect(mockHandler.request.uri.queryParameters,
          {'include': 'author', 'fields[author]': 'name', 'foo': 'bar'});
      expect(mockHandler.request.headers, {
        'Accept': ['application/vnd.api+json'],
        'foo': ['bar']
      });

      expect(response.meta, {'hello': 'world'});
    });
  });

  group('Fetch Related Resource', () {
    test('Min', () async {
      mockHandler.response = mock.primaryResource();
      final response =
          await client.fetchRelatedResource('articles', '1', 'author');
      expect(response.resource?.type, 'articles');
      expect(response.included.length, 3);
      expect(mockHandler.request.method, equals('get'));
      expect(mockHandler.request.uri.toString(), '/articles/1/author');
      expect(mockHandler.request.headers, {
        'Accept': ['application/vnd.api+json']
      });
    });

    test('Full', () async {
      mockHandler.response = mock.primaryResource();
      final response = await client
          .fetchRelatedResource('articles', '1', 'author', headers: {
        'foo': ['bar']
      }, query: [
        Query({
          'foo': ['bar']
        }),
        Include(['author']),
        Fields({
          'author': ['name']
        })
      ]);
      expect(response.resource?.type, 'articles');
      expect(response.included.length, 3);
      expect(mockHandler.request.method, equals('get'));
      expect(mockHandler.request.uri.path, '/articles/1/author');
      expect(mockHandler.request.uri.queryParameters,
          {'include': 'author', 'fields[author]': 'name', 'foo': 'bar'});
      expect(mockHandler.request.headers, {
        'Accept': ['application/vnd.api+json'],
        'foo': ['bar']
      });

      expect(response.meta, {'hello': 'world'});
    });

    test('Missing resource', () async {
      mockHandler.response = mock.relatedResourceNull();
      final response =
          await client.fetchRelatedResource('articles', '1', 'author');
      expect(response.resource, isNull);
      expect(response.included, isEmpty);
      expect(mockHandler.request.method, equals('get'));
      expect(mockHandler.request.uri.toString(), '/articles/1/author');
      expect(mockHandler.request.headers, {
        'Accept': ['application/vnd.api+json']
      });
    });
  });

  group('Fetch Relationship', () {
    test('Min', () async {
      mockHandler.response = mock.one();
      final response = await client.fetchToOne('articles', '1', 'author');
      expect(response.included.length, 3);
      expect(mockHandler.request.method, equals('get'));
      expect(mockHandler.request.uri.toString(),
          '/articles/1/relationships/author');
      expect(mockHandler.request.headers, {
        'Accept': ['application/vnd.api+json']
      });
    });

    test('Full', () async {
      mockHandler.response = mock.one();
      final response =
          await client.fetchToOne('articles', '1', 'author', headers: {
        'foo': ['bar']
      }, query: [
        Query({
          'foo': ['bar']
        })
      ]);
      expect(response.included.length, 3);
      expect(mockHandler.request.method, equals('get'));
      expect(mockHandler.request.uri.path, '/articles/1/relationships/author');
      expect(mockHandler.request.uri.queryParameters, {'foo': 'bar'});
      expect(mockHandler.request.headers, {
        'Accept': ['application/vnd.api+json'],
        'foo': ['bar']
      });
    });
  });

  group('Create New Resource', () {
    test('Min', () async {
      mockHandler.response = mock.primaryResource();
      final response = await client.createNew('articles');
      expect(response.resource.type, 'articles');
      expect(
          response.links['self'].toString(), 'http://example.com/articles/1');
      expect(response.included.length, 3);
      expect(mockHandler.request.method, equals('post'));
      expect(mockHandler.request.uri.toString(), '/articles');
      expect(mockHandler.request.headers, {
        'Accept': ['application/vnd.api+json'],
        'Content-Type': ['application/vnd.api+json']
      });
      expect(jsonDecode(await mockHandler.request.body.decode(utf8)), {
        'data': {'type': 'articles'}
      });
    });

    test('Full', () async {
      mockHandler.response = mock.primaryResource();
      final response = await client.createNew('articles', attributes: {
        'cool': true
      }, one: {
        'author': Identifier('people', '42')..meta.addAll({'hey': 'yos'})
      }, many: {
        'tags': [Identifier('tags', '1'), Identifier('tags', '2')]
      }, meta: {
        'answer': 42
      }, documentMeta: {
        'hello': 'world'
      }, headers: {
        'foo': ['bar']
      });
      expect(response.resource.type, 'articles');
      expect(
          response.links['self'].toString(), 'http://example.com/articles/1');
      expect(response.included.length, 3);
      expect(mockHandler.request.method, equals('post'));
      expect(mockHandler.request.uri.toString(), '/articles');
      expect(mockHandler.request.headers, {
        'Accept': ['application/vnd.api+json'],
        'Content-Type': ['application/vnd.api+json'],
        'foo': ['bar']
      });
      expect(jsonDecode(await mockHandler.request.body.decode(utf8)), {
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
        },
        'meta': {'hello': 'world'}
      });

      expect(response.meta, {'hello': 'world'});
    });
  });

  group('Create Resource', () {
    test('Min', () async {
      mockHandler.response = mock.primaryResource();
      final response = await client.create('articles', '1');
      expect(response.resource?.type, 'articles');
      expect(mockHandler.request.method, equals('post'));
      expect(mockHandler.request.uri.toString(), '/articles');
      expect(mockHandler.request.headers, {
        'Accept': ['application/vnd.api+json'],
        'Content-Type': ['application/vnd.api+json']
      });
      expect(jsonDecode(await mockHandler.request.body.decode(utf8)), {
        'data': {'type': 'articles', 'id': '1'}
      });
    });

    test('Min with 204 No Content', () async {
      mockHandler.response = mock.noContent();
      final response = await client.create('articles', '1');
      expect(response.resource, isNull);
      expect(mockHandler.request.method, equals('post'));
      expect(mockHandler.request.uri.toString(), '/articles');
      expect(mockHandler.request.headers, {
        'Accept': ['application/vnd.api+json'],
        'Content-Type': ['application/vnd.api+json']
      });
      expect(jsonDecode(await mockHandler.request.body.decode(utf8)), {
        'data': {'type': 'articles', 'id': '1'}
      });
    });

    test('Full', () async {
      mockHandler.response = mock.primaryResource();
      final response = await client.create('articles', '1', attributes: {
        'cool': true
      }, one: {
        'author': Identifier('people', '42')..meta.addAll({'hey': 'yos'})
      }, many: {
        'tags': [Identifier('tags', '1'), Identifier('tags', '2')]
      }, meta: {
        'answer': 42
      }, documentMeta: {
        'hello': 'world'
      }, headers: {
        'foo': ['bar']
      });
      expect(response.resource?.type, 'articles');
      expect(mockHandler.request.method, equals('post'));
      expect(mockHandler.request.uri.toString(), '/articles');
      expect(mockHandler.request.headers, {
        'Accept': ['application/vnd.api+json'],
        'Content-Type': ['application/vnd.api+json'],
        'foo': ['bar']
      });
      expect(jsonDecode(await mockHandler.request.body.decode(utf8)), {
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
        },
        'meta': {'hello': 'world'}
      });

      expect(response.meta, {'hello': 'world'});
    });
  });

  group('Update Resource', () {
    test('Min', () async {
      mockHandler.response = mock.primaryResource();
      final response = await client.updateResource('articles', '1');
      expect(response.resource?.type, 'articles');
      expect(mockHandler.request.method, equals('patch'));
      expect(mockHandler.request.uri.toString(), '/articles/1');
      expect(mockHandler.request.headers, {
        'Accept': ['application/vnd.api+json'],
        'Content-Type': ['application/vnd.api+json']
      });
      expect(jsonDecode(await mockHandler.request.body.decode(utf8)), {
        'data': {'type': 'articles', 'id': '1'}
      });
    });

    test('Min with 204 No Content', () async {
      mockHandler.response = mock.noContent();
      final response = await client.updateResource('articles', '1');
      expect(response.resource, isNull);
      expect(mockHandler.request.method, equals('patch'));
      expect(mockHandler.request.uri.toString(), '/articles/1');
      expect(mockHandler.request.headers, {
        'Accept': ['application/vnd.api+json'],
        'Content-Type': ['application/vnd.api+json']
      });
      expect(jsonDecode(await mockHandler.request.body.decode(utf8)), {
        'data': {'type': 'articles', 'id': '1'}
      });
    });

    test('Full', () async {
      mockHandler.response = mock.primaryResource();
      final response =
          await client.updateResource('articles', '1', attributes: {
        'cool': true
      }, one: {
        'author': Identifier('people', '42')..meta.addAll({'hey': 'yos'})
      }, many: {
        'tags': [Identifier('tags', '1'), Identifier('tags', '2')]
      }, meta: {
        'answer': 42
      }, documentMeta: {
        'hello': 'world'
      }, headers: {
        'foo': ['bar']
      });
      expect(response.resource?.type, 'articles');
      expect(mockHandler.request.method, equals('patch'));
      expect(mockHandler.request.uri.toString(), '/articles/1');
      expect(mockHandler.request.headers, {
        'Accept': ['application/vnd.api+json'],
        'Content-Type': ['application/vnd.api+json'],
        'foo': ['bar']
      });
      expect(jsonDecode(await mockHandler.request.body.decode(utf8)), {
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
        },
        'meta': {'hello': 'world'}
      });

      expect(response.meta, {'hello': 'world'});
    });
  });

  group('Replace One', () {
    test('Min', () async {
      mockHandler.response = mock.one();
      final response = await client.replaceToOne(
          'articles', '1', 'author', Identifier('people', '42'));
      expect(response.relationship, isA<ToOne>());
      expect(mockHandler.request.method, equals('patch'));
      expect(mockHandler.request.uri.toString(),
          '/articles/1/relationships/author');
      expect(mockHandler.request.headers, {
        'Accept': ['application/vnd.api+json'],
        'Content-Type': ['application/vnd.api+json']
      });
      expect(jsonDecode(await mockHandler.request.body.decode(utf8)), {
        'data': {'type': 'people', 'id': '42'}
      });
    });

    test('Full', () async {
      mockHandler.response = mock.one();
      final response = await client.replaceToOne(
          'articles', '1', 'author', Identifier('people', '42'),
          meta: {
            'hello': 'world'
          },
          headers: {
            'foo': ['bar']
          });
      expect(response.relationship, isA<ToOne>());
      expect(mockHandler.request.method, equals('patch'));
      expect(mockHandler.request.uri.toString(),
          '/articles/1/relationships/author');
      expect(mockHandler.request.headers, {
        'Accept': ['application/vnd.api+json'],
        'Content-Type': ['application/vnd.api+json'],
        'foo': ['bar']
      });
      expect(jsonDecode(await mockHandler.request.body.decode(utf8)), {
        'data': {'type': 'people', 'id': '42'},
        'meta': {'hello': 'world'}
      });
    });

    test('Throws RequestFailure', () async {
      mockHandler.response = mock.error422();
      try {
        await client.replaceToOne(
            'articles', '1', 'author', Identifier('people', '42'));
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.httpResponse.statusCode, 422);
        expect(e.errors.first.status, '422');
      }
    });

    test('Throws FormatException', () async {
      mockHandler.response = mock.many();
      expect(
          () => client.replaceToOne(
              'articles', '1', 'author', Identifier('people', '42')),
          throwsFormatException);
    });
  });

  group('Delete One', () {
    test('Min', () async {
      mockHandler.response = mock.oneEmpty();
      final response = await client.deleteToOne('articles', '1', 'author');
      expect(response.relationship, isA<ToOne>());
      expect(response.relationship!.identifier, isNull);
      expect(mockHandler.request.method, equals('patch'));
      expect(mockHandler.request.uri.toString(),
          '/articles/1/relationships/author');
      expect(mockHandler.request.headers, {
        'Accept': ['application/vnd.api+json'],
        'Content-Type': ['application/vnd.api+json']
      });
      expect(jsonDecode(await mockHandler.request.body.decode(utf8)),
          {'data': null});
    });

    test('Full', () async {
      mockHandler.response = mock.oneEmpty();
      final response =
          await client.deleteToOne('articles', '1', 'author', headers: {
        'foo': ['bar']
      });
      expect(response.relationship, isA<ToOne>());
      expect(response.relationship!.identifier, isNull);
      expect(mockHandler.request.method, equals('patch'));
      expect(mockHandler.request.uri.toString(),
          '/articles/1/relationships/author');
      expect(mockHandler.request.headers, {
        'Accept': ['application/vnd.api+json'],
        'Content-Type': ['application/vnd.api+json'],
        'foo': ['bar']
      });
      expect(jsonDecode(await mockHandler.request.body.decode(utf8)),
          {'data': null});
    });

    test('Throws RequestFailure', () async {
      mockHandler.response = mock.error422();
      try {
        await client.deleteToOne('articles', '1', 'author');
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.httpResponse.statusCode, 422);
        expect(e.errors.first.status, '422');
      }
    });

    test('Throws FormatException', () async {
      mockHandler.response = mock.many();
      expect(() => client.deleteToOne('articles', '1', 'author'),
          throwsFormatException);
    });
  });

  group('Delete Many', () {
    test('Min', () async {
      mockHandler.response = mock.many();
      final response = await client
          .deleteFromMany('articles', '1', 'tags', [Identifier('tags', '1')]);
      expect(response.relationship, isA<ToMany>());
      expect(mockHandler.request.method, equals('delete'));
      expect(
          mockHandler.request.uri.toString(), '/articles/1/relationships/tags');
      expect(mockHandler.request.headers, {
        'Accept': ['application/vnd.api+json'],
        'Content-Type': ['application/vnd.api+json']
      });
      expect(jsonDecode(await mockHandler.request.body.decode(utf8)), {
        'data': [
          {'type': 'tags', 'id': '1'}
        ]
      });
    });

    test('Full', () async {
      mockHandler.response = mock.many();
      final response = await client.deleteFromMany('articles', '1', 'tags', [
        Identifier('tags', '1')
      ], meta: {
        'hello': 'world'
      }, headers: {
        'foo': ['bar']
      });
      expect(response.relationship, isA<ToMany>());
      expect(mockHandler.request.method, equals('delete'));
      expect(
          mockHandler.request.uri.toString(), '/articles/1/relationships/tags');
      expect(mockHandler.request.headers, {
        'Accept': ['application/vnd.api+json'],
        'Content-Type': ['application/vnd.api+json'],
        'foo': ['bar']
      });
      expect(jsonDecode(await mockHandler.request.body.decode(utf8)), {
        'data': [
          {'type': 'tags', 'id': '1'}
        ],
        'meta': {'hello': 'world'}
      });
    });

    test('Throws RequestFailure', () async {
      mockHandler.response = mock.error422();
      try {
        await client
            .deleteFromMany('articles', '1', 'tags', [Identifier('tags', '1')]);
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.httpResponse.statusCode, 422);
        expect(e.errors.first.status, '422');
      }
    });

    test('Throws FormatException', () async {
      mockHandler.response = mock.one();
      expect(
          () => client.deleteFromMany(
              'articles', '1', 'tags', [Identifier('tags', '1')]),
          throwsFormatException);
    });
  });

  group('Replace Many', () {
    test('Min', () async {
      mockHandler.response = mock.many();
      final response = await client
          .replaceToMany('articles', '1', 'tags', [Identifier('tags', '1')]);
      expect(response.relationship, isA<ToMany>());
      expect(mockHandler.request.method, equals('patch'));
      expect(
          mockHandler.request.uri.toString(), '/articles/1/relationships/tags');
      expect(mockHandler.request.headers, {
        'Accept': ['application/vnd.api+json'],
        'Content-Type': ['application/vnd.api+json']
      });
      expect(jsonDecode(await mockHandler.request.body.decode(utf8)), {
        'data': [
          {'type': 'tags', 'id': '1'}
        ]
      });
    });

    test('Full', () async {
      mockHandler.response = mock.many();
      final response = await client.replaceToMany('articles', '1', 'tags', [
        Identifier('tags', '1')
      ], meta: {
        'hello': 'world'
      }, headers: {
        'foo': ['bar']
      });
      expect(response.relationship, isA<ToMany>());
      expect(mockHandler.request.method, equals('patch'));
      expect(
          mockHandler.request.uri.toString(), '/articles/1/relationships/tags');
      expect(mockHandler.request.headers, {
        'Accept': ['application/vnd.api+json'],
        'Content-Type': ['application/vnd.api+json'],
        'foo': ['bar']
      });
      expect(jsonDecode(await mockHandler.request.body.decode(utf8)), {
        'data': [
          {'type': 'tags', 'id': '1'}
        ],
        'meta': {'hello': 'world'}
      });
    });

    test('Throws RequestFailure', () async {
      mockHandler.response = mock.error422();
      try {
        await client
            .replaceToMany('articles', '1', 'tags', [Identifier('tags', '1')]);
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.httpResponse.statusCode, 422);
        expect(e.errors.first.status, '422');
      }
    });

    test('Throws FormatException', () async {
      mockHandler.response = mock.one();
      expect(
          () => client.replaceToMany(
              'articles', '1', 'tags', [Identifier('tags', '1')]),
          throwsFormatException);
    });
  });

  group('Add Many', () {
    test('Min', () async {
      mockHandler.response = mock.many();
      final response = await client
          .addMany('articles', '1', 'tags', [Identifier('tags', '1')]);
      expect(response.relationship, isA<ToMany>());
      expect(mockHandler.request.method, equals('post'));
      expect(
          mockHandler.request.uri.toString(), '/articles/1/relationships/tags');
      expect(mockHandler.request.headers, {
        'Accept': ['application/vnd.api+json'],
        'Content-Type': ['application/vnd.api+json']
      });
      expect(jsonDecode(await mockHandler.request.body.decode(utf8)), {
        'data': [
          {'type': 'tags', 'id': '1'}
        ]
      });
    });

    test('Full', () async {
      mockHandler.response = mock.many();
      final response = await client.addMany('articles', '1', 'tags', [
        Identifier('tags', '1')
      ], meta: {
        'hello': 'world'
      }, headers: {
        'foo': ['bar']
      });
      expect(response.relationship, isA<ToMany>());
      expect(mockHandler.request.method, equals('post'));
      expect(
          mockHandler.request.uri.toString(), '/articles/1/relationships/tags');
      expect(mockHandler.request.headers, {
        'Accept': ['application/vnd.api+json'],
        'Content-Type': ['application/vnd.api+json'],
        'foo': ['bar']
      });
      expect(jsonDecode(await mockHandler.request.body.decode(utf8)), {
        'data': [
          {'type': 'tags', 'id': '1'}
        ],
        'meta': {'hello': 'world'}
      });
    });

    test('Throws RequestFailure', () async {
      mockHandler.response = mock.error422();
      try {
        await client
            .addMany('articles', '1', 'tags', [Identifier('tags', '1')]);
        fail('Exception expected');
      } on RequestFailure catch (e) {
        expect(e.httpResponse.statusCode, 422);
        expect(e.errors.first.status, '422');
        expect(e.toString(), contains('422'));
      }
    });

    test('Throws FormatException', () async {
      mockHandler.response = mock.one();
      expect(
          () => client
              .addMany('articles', '1', 'tags', [Identifier('tags', '1')]),
          throwsFormatException);
    });
  });
}
