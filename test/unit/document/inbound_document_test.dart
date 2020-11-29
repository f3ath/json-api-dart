import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/src/test/payload.dart' as payload;
import 'package:test/test.dart';

void main() {
  group('InboundDocument', () {
    group('Errors', () {
      test('Minimal', () {
        final e = InboundDocument({
          'errors': [{}]
        }).errors.first;
        expect(e.id, '');
        expect(e.status, '');
        expect(e.code, '');
        expect(e.title, '');
        expect(e.detail, '');
        expect(e.source.parameter, '');
        expect(e.source.pointer, '');
        expect(e.source.isEmpty, true);
        expect(e.source.isNotEmpty, false);
        expect(e.links, isEmpty);
        expect(e.meta, isEmpty);
      });
      test('Full', () {
        final error = {
          'id': 'test_id',
          'status': 'test_status',
          'code': 'test_code',
          'title': 'test_title',
          'detail': 'test_detail',
          'source': {'parameter': 'test_parameter', 'pointer': 'test_pointer'},
          'links': {'foo': '/bar'},
          'meta': {'foo': 42},
        };
        final e = InboundDocument({
          'errors': [error]
        }).errors.first;

        expect(e.id, 'test_id');
        expect(e.status, 'test_status');
        expect(e.code, 'test_code');
        expect(e.title, 'test_title');
        expect(e.detail, 'test_detail');
        expect(e.source.parameter, 'test_parameter');
        expect(e.source.pointer, 'test_pointer');
        expect(e.source.isEmpty, false);
        expect(e.source.isNotEmpty, true);
        expect(e.links['foo'].toString(), '/bar');
        expect(e.meta['foo'], 42);
      });

      test('Invalid', () {
        expect(
            () => InboundDocument({
                  'errors': [
                    {'id': []}
                  ]
                }).errors.first,
            throwsFormatException);
      });
    });

    group('Parsing', () {
      test('can parse the standard example', () {
        final doc = InboundDocument(payload.example);
        expect(
            doc
                .resourceCollection()
                .first
                .relationships['author']!
                .links['self']!
                .uri
                .toString(),
            'http://example.com/articles/1/relationships/author');
        expect(doc.included.first.attributes['firstName'], 'Dan');
        expect(doc.links['self'].toString(), 'http://example.com/articles');
        expect(doc.meta, isEmpty);
      });

      test('can parse primary resource', () {
        final doc = InboundDocument(payload.resource);
        final article = doc.resource();
        expect(article.ref.id, '1');
        expect(article.attributes['title'], 'JSON:API paints my bikeshed!');
        expect(article.relationships['author'], isA<Relationship>());
        expect(doc.included, isEmpty);
        expect(doc.links['self'].toString(), 'http://example.com/articles/1');
        expect(doc.meta, isEmpty);
      });

      test('can parse a new resource', () {
        final doc = InboundDocument(payload.newResource);
        final article = doc.newResource();
        expect(article.attributes['title'], 'A new article');
        expect(doc.included, isEmpty);
        expect(doc.links, isEmpty);
        expect(doc.meta, isEmpty);
      });

      test('newResource() has id if data is sufficient', () {
        final doc = InboundDocument(payload.resource);
        final article = doc.newResource();
        expect(article.id, isNotEmpty);
      });

      test('can parse related resource', () {
        final doc = InboundDocument(payload.relatedEmpty);
        expect(doc.nullableResource(), isNull);
        expect(doc.included, isEmpty);
        expect(doc.links['self'].toString(),
            'http://example.com/articles/1/author');
        expect(doc.meta, isEmpty);
      });

      test('can parse to-one', () {
        final doc = InboundDocument(payload.one);
        expect(doc.dataAsRelationship(), isA<ToOne>());
        expect(doc.dataAsRelationship(), isNotEmpty);
        expect(doc.dataAsRelationship().first.ref.type, 'people');
        expect(doc.included, isEmpty);
        expect(
            doc.links['self'].toString(), '/articles/1/relationships/author');
        expect(doc.meta, isEmpty);
      });

      test('can parse empty to-one', () {
        final doc = InboundDocument(payload.oneEmpty);
        expect(doc.dataAsRelationship(), isA<ToOne>());
        expect(doc.dataAsRelationship(), isEmpty);
        expect(doc.included, isEmpty);
        expect(
            doc.links['self'].toString(), '/articles/1/relationships/author');
        expect(doc.meta, isEmpty);
      });

      test('can parse to-many', () {
        final doc = InboundDocument(payload.many);
        expect(doc.dataAsRelationship(), isA<ToMany>());
        expect(doc.dataAsRelationship(), isNotEmpty);
        expect(doc.dataAsRelationship().first.ref.type, 'tags');
        expect(doc.included, isEmpty);
        expect(doc.links['self'].toString(), '/articles/1/relationships/tags');
        expect(doc.meta, isEmpty);
      });

      test('can parse empty to-many', () {
        final doc = InboundDocument(payload.manyEmpty);
        expect(doc.dataAsRelationship(), isA<ToMany>());
        expect(doc.dataAsRelationship(), isEmpty);
        expect(doc.included, isEmpty);
        expect(doc.links['self'].toString(), '/articles/1/relationships/tags');
        expect(doc.meta, isEmpty);
      });

      test('throws on invalid doc', () {
        expect(() => InboundDocument(payload.manyEmpty).nullableResource(),
            throwsFormatException);
        expect(() => InboundDocument(payload.newResource).resource(),
            throwsFormatException);
        expect(() => InboundDocument(payload.newResource).nullableResource(),
            throwsFormatException);
        expect(() => InboundDocument({}).nullableResource(),
            throwsFormatException);
        expect(() => InboundDocument({'data': 42}).dataAsRelationship(),
            throwsFormatException);
        expect(
            () => InboundDocument({
                  'links': {'self': 42}
                }).dataAsRelationship(),
            throwsFormatException);
      });

      test('throws on invalid JSON', () {
        expect(() => InboundDocument.decode(jsonEncode('oops')),
            throwsFormatException);
      });

      test('throws on invalid relationship kind', () {
        expect(() => InboundDocument(payload.one).dataAsRelationship<ToMany>(),
            throwsFormatException);
        expect(() => InboundDocument(payload.many).dataAsRelationship<ToOne>(),
            throwsFormatException);
      });
    });
  });
}
