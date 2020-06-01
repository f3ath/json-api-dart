import 'package:json_api/src/query/filter.dart';
import 'package:test/test.dart';

void main() {
  test('Can decode url', () {
    final uri = Uri.parse(
        '/articles?include=author&filter%5Barticles%5D=title%2Cbody&filter%5Bpeople%5D=name');
    final filter = Filter.fromUri(uri);
    expect(filter['articles'], ['title', 'body']);
    expect(filter['people'], ['name']);
  });

  test('Can add to uri', () {
    final filter = Filter({
      'articles': ['title', 'body'],
      'people': ['name']
    });
    final uri = Uri.parse('/articles');

    expect(filter.addToUri(uri).toString(),
        '/articles?filter%5Barticles%5D=title%2Cbody&filter%5Bpeople%5D=name');
  });
}
