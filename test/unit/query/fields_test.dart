import 'package:json_api/src/query/fields.dart';
import 'package:test/test.dart';

void main() {
  group('Fields', () {
    test('emptiness', () {
      expect(Fields().isEmpty, isTrue);
      expect(Fields().isNotEmpty, isFalse);

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

    test('add, remove, clear', () {
      final f = Fields();
      f['foo'] = ['bar'];
      f['bar'] = ['foo'];
      expect(f['foo'], ['bar']);
      expect(f['bar'], ['foo']);
      f.remove('foo');
      expect(f['foo'], isNull);
      f.clear();
      expect(f.isEmpty, isTrue);
    });

    test('can decode url without duplicate keys', () {
      final uri = Uri.parse(
          '/articles?include=author&fields%5Barticles%5D=title%2Cbody&fields%5Bpeople%5D=name');
      final fields = Fields.fromUri(uri);
      expect(fields['articles'], ['title', 'body']);
      expect(fields['people'], ['name']);
    });

    test('can decode url with duplicate keys', () {
      final uri = Uri.parse(
          '/articles?include=author&fields%5Barticles%5D=title%2Cbody&fields%5Bpeople%5D=name&fields%5Bpeople%5D=age');
      final fields = Fields.fromUri(uri);
      expect(fields['articles'], ['title', 'body']);
      expect(fields['people'], ['name', 'age']);
    });

    test('can convert to query parameters', () {
      expect(
          Fields({
            'articles': ['title', 'body'],
            'people': ['name']
          }).asQueryParameters,
          {'fields[articles]': ['title,body'], 'fields[people]': ['name']});
    });
  });
}
