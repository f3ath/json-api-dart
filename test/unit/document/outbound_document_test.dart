import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:test/test.dart';

void main() {
  group('OutboundDocument', () {
    group('Meta', () {
      test('The "meta" member must be always present', () {
        expect(toObject(OutboundDocument()), {'meta': {}});
      });
      test('full', () {
        expect(toObject(OutboundDocument()..meta['foo'] = true), {
          'meta': {'foo': true}
        });
      });
    });

    group('Error', () {
      test('minimal', () {
        expect(toObject(OutboundErrorDocument([])), {'errors': []});
      });
      test('full', () {
        expect(
            toObject(OutboundErrorDocument([ErrorObject(detail: 'Some issue')])
              ..meta['foo'] = 42),
            {
              'errors': [
                {'detail': 'Some issue'}
              ],
              'meta': {'foo': 42}
            });
      });
    });
  });

  group('Data', () {
    final book = Resource('books', '1');
    final author = Resource('people', '2');
    group('Resource', () {
      test('minimal', () {
        expect(toObject(OutboundDataDocument.resource(book)), {
          'data': {'type': 'books', 'id': '1'}
        });
      });
      test('full', () {
        expect(
            toObject(OutboundDataDocument.resource(book)
              ..meta['foo'] = 42
              ..included.add(author)
              ..links['self'] = Link(Uri.parse('/books/1'))),
            {
              'data': {'type': 'books', 'id': '1'},
              'links': {'self': '/books/1'},
              'included': [
                {'type': 'people', 'id': '2'}
              ],
              'meta': {'foo': 42}
            });
      });
    });

    group('Collection', () {
      test('minimal', () {
        expect(toObject(OutboundDataDocument.collection([])), {'data': []});
      });
      test('full', () {
        expect(
            toObject(OutboundDataDocument.collection([book])
              ..meta['foo'] = 42
              ..included.add(author)
              ..links['self'] = Link(Uri.parse('/books/1'))),
            {
              'data': [
                {'type': 'books', 'id': '1'}
              ],
              'links': {'self': '/books/1'},
              'included': [
                {'type': 'people', 'id': '2'}
              ],
              'meta': {'foo': 42}
            });
      });
    });

    group('One', () {
      test('minimal', () {
        expect(
            toObject(OutboundDataDocument.one(ToOne.empty())), {'data': null});
      });
      test('full', () {
        expect(
            toObject(OutboundDataDocument.one(ToOne(book.toIdentifier())
              ..meta['foo'] = 42
              ..links['self'] = Link(Uri.parse('/books/1')))
              ..included.add(author)),
            {
              'data': {'type': 'books', 'id': '1'},
              'links': {'self': '/books/1'},
              'included': [
                {'type': 'people', 'id': '2'}
              ],
              'meta': {'foo': 42}
            });
      });
    });

    group('Many', () {
      test('minimal', () {
        expect(toObject(OutboundDataDocument.many(ToMany([]))), {'data': []});
      });
      test('full', () {
        expect(
            toObject(OutboundDataDocument.many(ToMany([book.toIdentifier()])
              ..meta['foo'] = 42
              ..links['self'] = Link(Uri.parse('/books/1')))
              ..included.add(author)),
            {
              'data': [
                {'type': 'books', 'id': '1'}
              ],
              'links': {'self': '/books/1'},
              'included': [
                {'type': 'people', 'id': '2'}
              ],
              'meta': {'foo': 42}
            });
      });
    });
  });
}

Map<String, dynamic> toObject(v) => jsonDecode(jsonEncode(v));
