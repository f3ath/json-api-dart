import 'package:json_api/routing.dart';
import 'package:test/test.dart';

void main() {
  test('URIs start with slashes when no base provided', () {
    final r = StandardRouting();
    expect(r.collection('books').toString(), '/books');
    expect(r.resource('books', '42').toString(), '/books/42');
    expect(r.related('books', '42', 'author').toString(), '/books/42/author');
    expect(r.relationship('books', '42', 'author').toString(),
        '/books/42/relationships/author');
  });

  test('Authority is retained if exists in base', () {
    final r = StandardRouting(Uri.parse('https://example.com'));
    expect(r.collection('books').toString(), 'https://example.com/books');
    expect(
        r.resource('books', '42').toString(), 'https://example.com/books/42');
    expect(r.related('books', '42', 'author').toString(),
        'https://example.com/books/42/author');
    expect(r.relationship('books', '42', 'author').toString(),
        'https://example.com/books/42/relationships/author');
  });

  test('Authority is retained if exists in base (non-directory path)', () {
    final r = StandardRouting(Uri.parse('https://example.com/foo'));
    expect(r.collection('books').toString(), 'https://example.com/books');
    expect(
        r.resource('books', '42').toString(), 'https://example.com/books/42');
    expect(r.related('books', '42', 'author').toString(),
        'https://example.com/books/42/author');
    expect(r.relationship('books', '42', 'author').toString(),
        'https://example.com/books/42/relationships/author');
  });

  test('Authority and path is retained if exists in base (directory path)', () {
    final r = StandardRouting(Uri.parse('https://example.com/foo/'));
    expect(r.collection('books').toString(), 'https://example.com/foo/books');
    expect(r.resource('books', '42').toString(),
        'https://example.com/foo/books/42');
    expect(r.related('books', '42', 'author').toString(),
        'https://example.com/foo/books/42/author');
    expect(r.relationship('books', '42', 'author').toString(),
        'https://example.com/foo/books/42/relationships/author');
  });
}
