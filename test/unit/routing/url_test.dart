import 'package:json_api/core.dart';
import 'package:json_api/routing.dart';
import 'package:test/test.dart';

void main() {
  final collection = CollectionTarget('books');
  final ref = Ref('books', '42');
  final resource = ResourceTarget(ref);
  final related = RelatedTarget(ref, 'author');
  final relationship = RelationshipTarget(ref, 'author');

  test('uri generation', () {
    final url = RecommendedUrlDesign.pathOnly;
    expect(collection.map(url).toString(), '/books');
    expect(resource.map(url).toString(), '/books/42');
    expect(related.map(url).toString(), '/books/42/author');
    expect(relationship.map(url).toString(), '/books/42/relationships/author');
  });

  test('Authority is retained if exists in base', () {
    final url = RecommendedUrlDesign(Uri.parse('https://example.com'));
    expect(collection.map(url).toString(), 'https://example.com/books');
    expect(resource.map(url).toString(), 'https://example.com/books/42');
    expect(related.map(url).toString(), 'https://example.com/books/42/author');
    expect(relationship.map(url).toString(),
        'https://example.com/books/42/relationships/author');
  });

  test('Authority and path is retained if exists in base (directory path)', () {
    final url = RecommendedUrlDesign(Uri.parse('https://example.com/foo/'));
    expect(collection.map(url).toString(), 'https://example.com/foo/books');
    expect(resource.map(url).toString(), 'https://example.com/foo/books/42');
    expect(
        related.map(url).toString(), 'https://example.com/foo/books/42/author');
    expect(relationship.map(url).toString(),
        'https://example.com/foo/books/42/relationships/author');
  });
}
