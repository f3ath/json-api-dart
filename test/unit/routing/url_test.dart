import 'package:json_api/routing.dart';
import 'package:test/test.dart';

void main() {
  test('uri generation', () {
    final d = StandardUriDesign.pathOnly;
    expect(d.collection('books').toString(), '/books');
    expect(d.resource('books', '42').toString(), '/books/42');
    expect(d.related('books', '42', 'author').toString(), '/books/42/author');
    expect(d.relationship('books', '42', 'author').toString(),
        '/books/42/relationships/author');
  });

  test('Authority is retained if exists in base', () {
    final d = StandardUriDesign(Uri.parse('https://example.com:8080'));
    expect(d.collection('books').toString(), 'https://example.com:8080/books');
    expect(d.resource('books', '42').toString(),
        'https://example.com:8080/books/42');
    expect(d.related('books', '42', 'author').toString(),
        'https://example.com:8080/books/42/author');
    expect(d.relationship('books', '42', 'author').toString(),
        'https://example.com:8080/books/42/relationships/author');
  });

  test('Host and path is retained if exists in base (directory path)', () {
    final d = StandardUriDesign(Uri.parse('https://example.com/foo/'));
    expect(d.collection('books').toString(), 'https://example.com/foo/books');
    expect(d.resource('books', '42').toString(),
        'https://example.com/foo/books/42');
    expect(d.related('books', '42', 'author').toString(),
        'https://example.com/foo/books/42/author');
    expect(d.relationship('books', '42', 'author').toString(),
        'https://example.com/foo/books/42/relationships/author');
  });
  group('Target matching', () {
    test('Path only', () {
      final d = StandardUriDesign.pathOnly;
      expect(d.matchTarget(Uri.parse('/books')), isA<Target>());
      expect(d.matchTarget(Uri.parse('/books/42')), isA<ResourceTarget>());
      expect(
          d.matchTarget(Uri.parse('/books/42/authors')), isA<RelatedTarget>());
      expect(d.matchTarget(Uri.parse('/books/42/relationships/authors')),
          isA<RelationshipTarget>());
      expect(d.matchTarget(Uri.parse('/a/b/c/d')), isNull);
    });
    test('Path only, full url', () {
      final d = StandardUriDesign.pathOnly;
      expect(
          d.matchTarget(Uri.parse('https://example.com/books')), isA<Target>());
      expect(d.matchTarget(Uri.parse('https://example.com/books/42')),
          isA<ResourceTarget>());
      expect(d.matchTarget(Uri.parse('https://example.com/books/42/authors')),
          isA<RelatedTarget>());
      expect(
          d.matchTarget(
              Uri.parse('https://example.com/books/42/relationships/authors')),
          isA<RelationshipTarget>());
      expect(d.matchTarget(Uri.parse('https://example.com/a/b/c/d')), isNull);
    });
    test('Authority', () {
      final d = StandardUriDesign(Uri.parse('https://example.com:8080'));
      expect(d.matchTarget(Uri.parse('https://example.com:8080/books')),
          isA<Target>());
      expect(d.matchTarget(Uri.parse('https://example.com:8080/books/42')),
          isA<ResourceTarget>());
      expect(
          d.matchTarget(Uri.parse('https://example.com:8080/books/42/authors')),
          isA<RelatedTarget>());
      expect(
          d.matchTarget(Uri.parse(
              'https://example.com:8080/books/42/relationships/authors')),
          isA<RelationshipTarget>());

      expect(
          d.matchTarget(Uri.parse('https://example.com:8080/a/b/c/d')), isNull);
      expect(d.matchTarget(Uri.parse('http://example.com:8080/books')), isNull);
      expect(d.matchTarget(Uri.parse('https://foo.net:8080/books')), isNull);
    });

    test('Authority and path', () {
      final d = StandardUriDesign(Uri.parse('https://example.com:8080/api'));
      expect(d.matchTarget(Uri.parse('https://example.com:8080/api/books')),
          isA<Target>().having((it) => it.type, 'type', equals('books')));
      expect(
          d.matchTarget(Uri.parse('https://example.com:8080/api/books/42')),
          isA<ResourceTarget>()
              .having((it) => it.type, 'type', equals('books'))
              .having((it) => it.id, 'id', equals('42')));
      expect(
          d.matchTarget(
              Uri.parse('https://example.com:8080/api/books/42/authors')),
          isA<RelatedTarget>()
              .having((it) => it.type, 'type', equals('books'))
              .having((it) => it.id, 'id', equals('42'))
              .having(
                  (it) => it.relationship, 'relationship', equals('authors')));
      expect(
          d.matchTarget(Uri.parse(
              'https://example.com:8080/api/books/42/relationships/authors')),
          isA<RelationshipTarget>()
              .having((it) => it.type, 'type', equals('books'))
              .having((it) => it.id, 'id', equals('42'))
              .having(
                  (it) => it.relationship, 'relationship', equals('authors')));

      expect(
          d.matchTarget(Uri.parse('https://example.com:8080/a/b/c/d')), isNull);
      expect(d.matchTarget(Uri.parse('http://example.com:8080/books')), isNull);
      expect(d.matchTarget(Uri.parse('https://foo.net:8080/books')), isNull);
      expect(d.matchTarget(Uri.parse('https://example.com:8080/foo/books')),
          isNull);
    });
  });
}
