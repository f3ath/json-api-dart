import 'package:json_api/routing.dart';
import 'package:test/test.dart';

void main() {
  test('uri generation', () {
    final url = StandardUriDesign.pathOnly;
    expect(url.collection('books').toString(), '/books');
    expect(url.resource('books', '42').toString(), '/books/42');
    expect(url.related('books', '42', 'author').toString(), '/books/42/author');
    expect(url.relationship('books', '42', 'author').toString(),
        '/books/42/relationships/author');
  });

  test('Authority is retained if exists in base', () {
    final url = StandardUriDesign(Uri.parse('https://example.com'));
    expect(url.collection('books').toString(), 'https://example.com/books');
    expect(
        url.resource('books', '42').toString(), 'https://example.com/books/42');
    expect(url.related('books', '42', 'author').toString(),
        'https://example.com/books/42/author');
    expect(url.relationship('books', '42', 'author').toString(),
        'https://example.com/books/42/relationships/author');
  });

  test('Authority and path is retained if exists in base (directory path)', () {
    final url = StandardUriDesign(Uri.parse('https://example.com/foo/'));
    expect(url.collection('books').toString(), 'https://example.com/foo/books');
    expect(url.resource('books', '42').toString(),
        'https://example.com/foo/books/42');
    expect(url.related('books', '42', 'author').toString(),
        'https://example.com/foo/books/42/author');
    expect(url.relationship('books', '42', 'author').toString(),
        'https://example.com/foo/books/42/relationships/author');
  });
}
