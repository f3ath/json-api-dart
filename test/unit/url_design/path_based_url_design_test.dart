import 'package:json_api/server.dart';
import 'package:json_api/url_design.dart';
import 'package:test/test.dart';

void main() {
  final routing = PathBasedUrlDesign(Uri.parse('http://example.com/api'));
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
    final doNotCall = ([a, b, c]) => throw 'Invalid match ${[a, b, c]}';

    test('Matches collection URL', () {
      expect(
          routing.matchAndMap(
              Uri.parse('http://example.com/api/books'), mapper),
          CollectionTarget('books'));
    });

    test('Matches resource URL', () {
      expect(
          routing.matchAndMap(
              Uri.parse('http://example.com/api/books/42'), mapper),
          ResourceTarget('books', '42'));
    });

    test('Matches related URL', () {
      expect(
          routing.matchAndMap(
              Uri.parse('http://example.com/api/books/42/authors'), mapper),
          RelationshipTarget('books', '42', 'authors'));
    });

    test('Matches relationship URL', () {
      expect(
          routing.matchAndMap(
              Uri.parse(
                  'http://example.com/api/books/42/relationships/authors'),
              mapper),
          RelationshipTarget('books', '42', 'authors'));
    });

    test('Does not match collection URL with incorrect path', () {
      expect(
          routing.matchAndMap(
              Uri.parse('http://example.com/foo/apples'), mapper),
          null);
    });

    test('Does not match collection URL with incorrect host', () {
      expect(
          routing.matchAndMap(
              Uri.parse('http://example.org/api/apples'), mapper),
          null);
    });

    test('Does not match collection URL with incorrect port', () {
      expect(
          routing.matchAndMap(
              Uri.parse('http://example.com:8080/api/apples'), mapper),
          null);
    });
  });
}

class _Mapper implements TargetMapper {
  @override
  collection(CollectionTarget target) => target;

  @override
  related(RelationshipTarget target) => target;

  @override
  relationship(RelationshipTarget target) => target;

  @override
  resource(ResourceTarget target) => target;

  @override
  unmatched() => null;
}
