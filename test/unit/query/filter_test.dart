import 'package:json_api/query.dart';
import 'package:test/test.dart';

void main() {
  group('Filter', () {
    test('emptiness', () {
      expect(Filter().isEmpty, isTrue);
      expect(Filter().isNotEmpty, isFalse);
      expect(Filter({'foo': 'bar'}).isEmpty, isFalse);
      expect(Filter({'foo': 'bar'}).isNotEmpty, isTrue);
    });

    test('add, remove, clear', () {
      final f = Filter();
      f['foo'] = 'bar';
      f['bar'] = 'foo';
      f['foobar'] = {'foo': 'bar'};
      expect(f['foo'], 'bar');
      expect(f['bar'], 'foo');
      expect(f['foobar'], {'foo': 'bar'});
      f.remove('foo');
      expect(f['foo'], isNull);
      f.clear();
      expect(f.isEmpty, isTrue);
    });

    test('Can decode url', () {
      final uri = Uri.parse('/articles?filter[post]=1,2&filter[author][id]=12');
      final filter = Filter.fromUri(uri);
      expect(filter['post'], '1,2');
      expect(filter['author'], {'id': '12'});
    });

    test('Can convert to query parameters', () {
      expect(
        Filter({
          'post': '1,2',
          'author': {'id': '12'}
        }).asQueryParameters,
        {'filter[post]': '1,2', 'filter[author][id]': '12'},
      );
    });
  });
}
