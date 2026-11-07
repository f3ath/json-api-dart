import 'package:json_api/routing.dart';
import 'package:test/test.dart';

void main() {
  test('uri generation', () {
    final d = StandardUriDesign.pathOnly;
    expect(d.base.path, equals('/'));
    expect(d.uri(const CollectionTarget('books')).toString(), '/books');
    expect(d.uri(const ResourceTarget('books', '42')).toString(), '/books/42');
    expect(d.uri(const RelatedTarget('books', '42', 'author')).toString(), '/books/42/author');
    expect(
      d.uri(const RelationshipTarget('books', '42', 'author')).toString(),
      '/books/42/relationships/author',
    );
  });

  test('uri generation with base, trailing slash', () {
    final d = StandardUriDesign(Uri.parse('https://example.com/api/'));
    expect(d.base.path, equals('/api/'));
    expect(d.uri(const CollectionTarget('books')).toString(), 'https://example.com/api/books');
    expect(
      d.uri(const ResourceTarget('books', '42')).toString(),
      'https://example.com/api/books/42',
    );
    expect(
      d.uri(const RelatedTarget('books', '42', 'author')).toString(),
      'https://example.com/api/books/42/author',
    );
    expect(
      d.uri(const RelationshipTarget('books', '42', 'author')).toString(),
      'https://example.com/api/books/42/relationships/author',
    );
  });

  test('uri generation with base, no trailing slash', () {
    final d = StandardUriDesign(Uri.parse('https://example.com/api'));
    expect(d.base.path, equals('/api/'));
    expect(d.uri(const CollectionTarget('books')).toString(), 'https://example.com/api/books');
    expect(
      d.uri(const ResourceTarget('books', '42')).toString(),
      'https://example.com/api/books/42',
    );
    expect(
      d.uri(const RelatedTarget('books', '42', 'author')).toString(),
      'https://example.com/api/books/42/author',
    );
    expect(
      d.uri(const RelationshipTarget('books', '42', 'author')).toString(),
      'https://example.com/api/books/42/relationships/author',
    );
  });

  test('Authority is retained if exists in base', () {
    final d = StandardUriDesign(Uri.parse('https://example.com:8080'));
    expect(d.uri(const CollectionTarget('books')).toString(), 'https://example.com:8080/books');
    expect(
      d.uri(const ResourceTarget('books', '42')).toString(),
      'https://example.com:8080/books/42',
    );
    expect(
      d.uri(const RelatedTarget('books', '42', 'author')).toString(),
      'https://example.com:8080/books/42/author',
    );
    expect(
      d.uri(const RelationshipTarget('books', '42', 'author')).toString(),
      'https://example.com:8080/books/42/relationships/author',
    );
  });

  test('Host and path is retained if exists in base (directory path)', () {
    final d = StandardUriDesign(Uri.parse('https://example.com/foo/'));
    expect(d.uri(const CollectionTarget('books')).toString(), 'https://example.com/foo/books');
    expect(
      d.uri(const ResourceTarget('books', '42')).toString(),
      'https://example.com/foo/books/42',
    );
    expect(
      d.uri(const RelatedTarget('books', '42', 'author')).toString(),
      'https://example.com/foo/books/42/author',
    );
    expect(
      d.uri(const RelationshipTarget('books', '42', 'author')).toString(),
      'https://example.com/foo/books/42/relationships/author',
    );
  });
  group('Target matching', () {
    test('Path only', () {
      final d = StandardUriDesign.pathOnly;
      expect(d.target(Uri.parse('/books')), isA<Target>());
      expect(d.target(Uri.parse('/books/42')), isA<ResourceTarget>());
      expect(d.target(Uri.parse('/books/42/authors')), isA<RelatedTarget>());
      expect(d.target(Uri.parse('/books/42/relationships/authors')), isA<RelationshipTarget>());
      expect(d.target(Uri.parse('/a/b/c/d')), isNull);
    });
    test('Path only, full url', () {
      final d = StandardUriDesign.pathOnly;
      expect(d.target(Uri.parse('https://example.com/books')), isA<Target>());
      expect(d.target(Uri.parse('https://example.com/books/42')), isA<ResourceTarget>());
      expect(d.target(Uri.parse('https://example.com/books/42/authors')), isA<RelatedTarget>());
      expect(
        d.target(Uri.parse('https://example.com/books/42/relationships/authors')),
        isA<RelationshipTarget>(),
      );
      expect(d.target(Uri.parse('https://example.com/a/b/c/d')), isNull);
    });
    test('Authority', () {
      final d = StandardUriDesign(Uri.parse('https://example.com:8080'));
      expect(d.target(Uri.parse('https://example.com:8080/books')), isA<Target>());
      expect(d.target(Uri.parse('https://example.com:8080/books/42')), isA<ResourceTarget>());
      expect(
        d.target(Uri.parse('https://example.com:8080/books/42/authors')),
        isA<RelatedTarget>(),
      );
      expect(
        d.target(Uri.parse('https://example.com:8080/books/42/relationships/authors')),
        isA<RelationshipTarget>(),
      );

      expect(d.target(Uri.parse('https://example.com:8080/a/b/c/d')), isNull);
      expect(d.target(Uri.parse('http://example.com:8080/books')), isNull);
      expect(d.target(Uri.parse('https://foo.net:8080/books')), isNull);
    });

    test('Authority and path', () {
      final d = StandardUriDesign(Uri.parse('https://example.com:8080/api'));
      expect(
        d.target(Uri.parse('https://example.com:8080/api/books')),
        isA<CollectionTarget>().having((it) => it.type, 'type', equals('books')),
      );
      expect(
        d.target(Uri.parse('https://example.com:8080/api/books/42')),
        isA<ResourceTarget>()
            .having((it) => it.type, 'type', equals('books'))
            .having((it) => it.id, 'id', equals('42')),
      );
      expect(
        d.target(Uri.parse('https://example.com:8080/api/books/42/authors')),
        isA<RelatedTarget>()
            .having((it) => it.type, 'type', equals('books'))
            .having((it) => it.id, 'id', equals('42'))
            .having((it) => it.relationship, 'relationship', equals('authors')),
      );
      expect(
        d.target(Uri.parse('https://example.com:8080/api/books/42/relationships/authors')),
        isA<RelationshipTarget>()
            .having((it) => it.type, 'type', equals('books'))
            .having((it) => it.id, 'id', equals('42'))
            .having((it) => it.relationship, 'relationship', equals('authors')),
      );

      expect(d.target(Uri.parse('https://example.com:8080/a/b/c/d')), isNull);
      expect(d.target(Uri.parse('http://example.com:8080/books')), isNull);
      expect(d.target(Uri.parse('https://foo.net:8080/books')), isNull);
      expect(d.target(Uri.parse('https://example.com:8080/foo/books')), isNull);
    });

    test('Authority and path, trailing slash', () {
      final d = StandardUriDesign(Uri.parse('https://example.com:8080/api/'));
      expect(
        d.target(Uri.parse('https://example.com:8080/api/books')),
        isA<CollectionTarget>().having((it) => it.type, 'type', equals('books')),
      );
      expect(
        d.target(Uri.parse('https://example.com:8080/api/books/42')),
        isA<ResourceTarget>()
            .having((it) => it.type, 'type', equals('books'))
            .having((it) => it.id, 'id', equals('42')),
      );
      expect(
        d.target(Uri.parse('https://example.com:8080/api/books/42/authors')),
        isA<RelatedTarget>()
            .having((it) => it.type, 'type', equals('books'))
            .having((it) => it.id, 'id', equals('42'))
            .having((it) => it.relationship, 'relationship', equals('authors')),
      );
      expect(
        d.target(Uri.parse('https://example.com:8080/api/books/42/relationships/authors')),
        isA<RelationshipTarget>()
            .having((it) => it.type, 'type', equals('books'))
            .having((it) => it.id, 'id', equals('42'))
            .having((it) => it.relationship, 'relationship', equals('authors')),
      );

      expect(d.target(Uri.parse('https://example.com:8080/a/b/c/d')), isNull);
      expect(d.target(Uri.parse('http://example.com:8080/books')), isNull);
      expect(d.target(Uri.parse('https://foo.net:8080/books')), isNull);
      expect(d.target(Uri.parse('https://example.com:8080/foo/books')), isNull);
    });
  });
}
