import 'package:json_api/query.dart';
import 'package:test/test.dart';

void main() {
  group('Page', () {
    test('emptiness', () {
      expect(Page().isEmpty, isTrue);
      expect(Page().isNotEmpty, isFalse);
      expect(Page({'foo': 'bar'}).isEmpty, isFalse);
      expect(Page({'foo': 'bar'}).isNotEmpty, isTrue);
    });

    test('add, remove, clear', () {
      final p = Page();
      p['foo'] = 'bar';
      p['bar'] = 'foo';
      expect(p['foo'], 'bar');
      expect(p['bar'], 'foo');
      p.remove('foo');
      expect(p['foo'], isNull);
      p.clear();
      expect(p.isEmpty, isTrue);
    });

    test('can decode url', () {
      final uri = Uri.parse('/articles?page[limit]=10&page[offset]=20');
      final page = Page.fromUri(uri);
      expect(page['limit'], '10');
      expect(page['offset'], '20');
    });

    test('can convert to query parameters', () {
      expect(Page({'limit': '10', 'offset': '20'}).asQueryParameters,
          {'page[limit]': ['10'], 'page[offset]': ['20']});
    });
  });
}
