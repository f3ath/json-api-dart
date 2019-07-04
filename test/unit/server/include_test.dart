import 'package:json_api/src/server/query/include.dart';
import 'package:test/test.dart';

void main() {
  test('Can decode url', () {
    final uri = Uri.parse('/articles/1?include=author,comments.author');
    final include = Include.decode(uri.queryParametersAll);
    expect(include.length, 2);
    expect(include.first, 'author');
    expect(include.last, 'comments.author');
  });
}
