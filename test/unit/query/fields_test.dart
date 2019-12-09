import 'package:json_api/src/query/fields.dart';
import 'package:test/test.dart';

void main() {
  test('Can decode url', () {
    final uri = Uri.parse(
        '/articles?include=author&fields%5Barticles%5D=title%2Cbody&fields%5Bpeople%5D=name');
    final fields = Fields.fromUri(uri);
    expect(fields['articles'], ['title', 'body']);
    expect(fields['people'], ['name']);
  });

  test('Can add to uri', () {
    final fields = Fields({
      'articles': ['title', 'body'],
      'people': ['name']
    });
    final uri = Uri.parse('/articles');

    expect(fields.addToUri(uri).toString(),
        '/articles?fields%5Barticles%5D=title%2Cbody&fields%5Bpeople%5D=name');
  });
}
