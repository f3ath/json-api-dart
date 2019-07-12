import 'package:json_api/src/query/include.dart';
import 'package:test/test.dart';

void main() {
  test('Can decode url', () {
    final uri = Uri.parse('/articles/1?include=author,comments.author');
    final include = Include.decode(uri.queryParametersAll);
    expect(include.length, 2);
    expect(include.first, 'author');
    expect(include.last, 'comments.author');
  });
  test('Can add to uri', () {
    final uri = Uri.parse('/articles/1');
    final include = Include(['author', 'comments.author']);
    expect(include.addTo(uri).toString(),
        '/articles/1?include=author%2Ccomments.author');
  });
}
