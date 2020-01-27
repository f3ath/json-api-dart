import 'package:json_api/src/query/include.dart';
import 'package:test/test.dart';

void main() {
  test('Can decode url without duplicate keys', () {
    final uri = Uri.parse('/articles/1?include=author,comments.author');
    final include = Include.fromUri(uri);
    expect(include, equals(['author', 'comments.author']));
  });

  test('Can decode url with duplicate keys', () {
    final uri =
        Uri.parse('/articles/1?include=author,comments.author&include=tags');
    final include = Include.fromUri(uri);
    expect(include, equals(['author', 'comments.author', 'tags']));
  });

  test('Can add to uri', () {
    final uri = Uri.parse('/articles/1');
    final include = Include(['author', 'comments.author']);
    expect(include.addToUri(uri).toString(),
        '/articles/1?include=author%2Ccomments.author');
  });
}
