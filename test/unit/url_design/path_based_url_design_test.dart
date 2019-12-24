import 'package:json_api/server.dart';
import 'package:json_api/url_design.dart';
import 'package:test/test.dart';

void main() {
  final routing =
      PathBasedUrlDesign(Uri.parse('http://example.com/api'), matchBase: true);
  final mapper = _Mapper();

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
    test('Matches collection URL', () {
      expect(routing.match(Uri.parse('http://example.com/api/books'), mapper),
          'collection:books');
    });

    test('Matches resource URL', () {
      expect(
          routing.match(Uri.parse('http://example.com/api/books/42'), mapper),
          'resource:books:42');
    });

    test('Matches related URL', () {
      expect(
          routing.match(
              Uri.parse('http://example.com/api/books/42/authors'), mapper),
          'related:books:42:authors');
    });

    test('Matches relationship URL', () {
      expect(
          routing.match(
              Uri.parse(
                  'http://example.com/api/books/42/relationships/authors'),
              mapper),
          'relationship:books:42:authors');
    });

    test('Does not match collection URL with incorrect path', () {
      expect(routing.match(Uri.parse('http://example.com/foo/apples'), mapper),
          'unmatched');
    });

    test('Does not match collection URL with incorrect host', () {
      expect(routing.match(Uri.parse('http://example.org/api/apples'), mapper),
          'unmatched');
    });

    test('Does not match collection URL with incorrect port', () {
      expect(
          routing.match(
              Uri.parse('http://example.com:8080/api/apples'), mapper),
          'unmatched');
    });
  });
}

class _Mapper implements MatchCase<String> {
  @override
  String unmatched() => 'unmatched';

  @override
  String collection(String type) => 'collection:$type';

  @override
  String related(String type, String id, String relationship) =>
      'related:$type:$id:$relationship';

  @override
  String relationship(String type, String id, String relationship) =>
      'relationship:$type:$id:$relationship';

  @override
  String resource(String type, String id) => 'resource:$type:$id';
}
