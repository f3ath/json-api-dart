import 'package:json_api/url_design.dart';
import 'package:test/test.dart';

void main() {
  final routing = PathBasedUrlDesign(Uri.parse('http://example.com/api'));

  group('URL construction', () {
    test('Collection URL adds type', () {
      expect(routing.collection('books').toString(),
          'http://example.com/api/books');
    });

    test('Resource URL adds type, ai', () {
      expect(routing.resource('books', '42').toString(),
          'http://example.com/api/books/42');
    });

    test('Related URL adds type, id, relationship', () {
      expect(routing.related('books', '42', 'sellers').toString(),
          'http://example.com/api/books/42/sellers');
    });

    test('Reltionship URL adds type, id, relationship', () {
      expect(routing.relationship('books', '42', 'sellers').toString(),
          'http://example.com/api/books/42/relationships/sellers');
    });
  });

  group('URL matching', () {
    String type;
    String id;
    String relationship;

    final doNotCall = ([a, b, c]) => throw 'Invalid match ${[a, b, c]}';

    setUp(() {
      type = null;
      id = null;
      relationship = null;
    });

    test('Matches collection URL', () {
      routing.match(
        Uri.parse('http://example.com/api/books'),
        onCollection: (_) => type = _,
        onResource: doNotCall,
        onRelationship: doNotCall,
        onRelated: doNotCall,
      );
      expect(type, 'books');
    });

    test('Matches resource URL', () {
      routing.match(
        Uri.parse('http://example.com/api/books/42'),
        onCollection: doNotCall,
        onResource: (a, b) {
          type = a;
          id = b;
        },
        onRelationship: doNotCall,
        onRelated: doNotCall,
      );
      expect(type, 'books');
      expect(id, '42');
    });

    test('Matches related URL', () {
      routing.match(
        Uri.parse('http://example.com/api/books/42/authors'),
        onCollection: doNotCall,
        onResource: doNotCall,
        onRelated: (a, b, c) {
          type = a;
          id = b;
          relationship = c;
        },
        onRelationship: doNotCall,
      );
      expect(type, 'books');
      expect(id, '42');
      expect(relationship, 'authors');
    });

    test('Matches relationship URL', () {
      routing.match(
        Uri.parse('http://example.com/api/books/42/relationships/authors'),
        onCollection: doNotCall,
        onResource: doNotCall,
        onRelationship: (a, b, c) {
          type = a;
          id = b;
          relationship = c;
        },
        onRelated: doNotCall,
      );
      expect(type, 'books');
      expect(id, '42');
      expect(relationship, 'authors');
    });

    test('Does not match collection URL with incorrect path', () {
      routing.match(
        Uri.parse('http://example.com/foo/apples'),
        onCollection: doNotCall,
        onResource: doNotCall,
        onRelationship: doNotCall,
        onRelated: doNotCall,
      );
    });

    test('Does not match collection URL with incorrect host', () {
      routing.match(
        Uri.parse('http://example.org/api/apples'),
        onCollection: doNotCall,
        onResource: doNotCall,
        onRelationship: doNotCall,
        onRelated: doNotCall,
      );
    });

    test('Does not match collection URL with incorrect port', () {
      routing.match(
        Uri.parse('http://example.com:8080/api/apples'),
        onCollection: doNotCall,
        onResource: doNotCall,
        onRelationship: doNotCall,
        onRelated: doNotCall,
      );
    });
  });
}
