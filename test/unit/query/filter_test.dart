import 'package:json_api/query.dart';
import 'package:json_api/src/query/filter.dart';
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
      expect(f['foo'], 'bar');
      expect(f['bar'], 'foo');
      f.remove('foo');
      expect(f['foo'], isNull);
      f.clear();
      expect(f.isEmpty, isTrue);
    });

    test('can decode url', () {
      final uri = Uri.parse('/articles?filter[foo]=10&filter[bar]=20');
      final filter = Filter.fromUri(uri);
      expect(filter['foo'], '10');
      expect(filter['bar'], '20');
    });

    test('can convert to query parameters', () {
      expect(Filter({'foo': '10', 'bar': '20'}).toQuery(), {
        'filter[foo]': ['10'],
        'filter[bar]': ['20'],
      });
    });
  });
}
