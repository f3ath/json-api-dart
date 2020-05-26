import 'package:json_api/src/query/fields.dart';
import 'package:test/test.dart';

void main() {
  test('emptiness', () {
    expect(Fields({}).isEmpty, isTrue);
    expect(Fields({}).isNotEmpty, isFalse);

    expect(
        Fields({
          'foo': ['bar']
        }).isEmpty,
        isFalse);
    expect(
        Fields({
          'foo': ['bar']
        }).isNotEmpty,
        isTrue);
  });
  test('Can decode url without duplicate keys', () {
    final uri = Uri.parse(
        '/articles?include=author&fields%5Barticles%5D=title%2Cbody&fields%5Bpeople%5D=name');
    final fields = Fields.fromUri(uri);
    expect(fields['articles'], ['title', 'body']);
    expect(fields['people'], ['name']);
  });

  test('Can decode url with duplicate keys', () {
    final uri = Uri.parse(
        '/articles?include=author&fields%5Barticles%5D=title%2Cbody&fields%5Bpeople%5D=name&fields%5Bpeople%5D=age');
    final fields = Fields.fromUri(uri);
    expect(fields['articles'], ['title', 'body']);
    expect(fields['people'], ['name', 'age']);
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
